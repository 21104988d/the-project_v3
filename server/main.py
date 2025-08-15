import os
import logging
import json
from dotenv import load_dotenv
from datetime import datetime, timedelta
from typing import Optional, List
import time
import uuid # Import uuid for request_id
import redis.asyncio as redis
from fastapi_limiter import FastAPILimiter
from fastapi_limiter.depends import RateLimiter

from fastapi import FastAPI, Depends, HTTPException, status, APIRouter, Request
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from jose import jwt, JWTError

from .database.database import Base, engine, get_db
from .database import models
from .auth import get_password_hash, verify_password
from .schemas import UserCreate, UserInDB, Token, TokenData, UserUpdate, TransactionCreate, TransactionInDB, KycSubmission, KycStatusResponse
from .hyperliquid_client import HyperliquidClient

# Configure structured logging
class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": datetime.fromtimestamp(record.created).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "name": record.name,
            "pathname": record.pathname,
            "lineno": record.lineno,
            "funcName": record.funcName,
            "process": record.process,
            "thread": record.thread,
        }
        if hasattr(record, 'request_id'):
            log_record['request_id'] = record.request_id
        if hasattr(record, 'user_id'):
            log_record['user_id'] = record.user_id
        if record.exc_info:
            log_record['exc_info'] = self.formatException(record.exc_info)
        return json.dumps(log_record)

handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.addHandler(handler)

# Load environment variables from .env file at the project root
load_dotenv(dotenv_path=os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env'))

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

if not SECRET_KEY:
    raise ValueError("SECRET_KEY environment variable not set.")

app = FastAPI()

@app.on_event("startup")
async def startup():
    redis_connection = redis.from_url("redis://localhost", encoding="utf8", decode_responses=True)
    await FastAPILimiter.init(redis_connection)

Base.metadata.create_all(bind=engine)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def get_user(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(db, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: models.User = Depends(get_current_user)):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

@app.middleware("http")
async def add_logging_middleware(request: Request, call_next):
    start_time = time.time()
    request_id = str(uuid.uuid4()) # Generate a unique request ID
    
    # Attach request_id to the request state for access in other parts of the app
    request.state.request_id = request_id

    logger.info(f"Request started: {request.method} {request.url}", extra={"request_id": request_id})
    
    response = await call_next(request)
    
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    logger.info(f"Request finished: {request.method} {request.url} - {process_time:.4f}s", extra={"request_id": request_id, "process_time": process_time})
    
    return response

@app.post("/register/", response_model=UserInDB, dependencies=[Depends(RateLimiter(times=5, minutes=1))])
def register_user(user: UserCreate, db: Session = Depends(get_db), request: Request = None):
    start_time = time.time()
    try:
        db_user = get_user(db, username=user.username)
        if db_user:
            logger.warning(f"Registration failed: Username already registered", extra={"request_id": request.state.request_id if request else None, "username": user.username})
            raise HTTPException(status_code=400, detail="Username already registered")
        db_user = db.query(models.User).filter(models.User.email == user.email).first()
        if db_user:
            logger.warning(f"Registration failed: Email already registered", extra={"request_id": request.state.request_id if request else None, "email": user.email})
            raise HTTPException(status_code=400, detail="Email already registered")
        
        hashed_password = get_password_hash(user.password)
        db_user = models.User(
            username=user.username, email=user.email, hashed_password=hashed_password
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        process_time = time.time() - start_time
        logger.info(f"User registered successfully: {user.username}", extra={"request_id": request.state.request_id if request else None, "username": user.username, "process_time": process_time})
        return db_user
    except Exception as e:
        logger.error(f"Error during registration: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "username": user.username})
        raise

@app.post("/token", response_model=Token, dependencies=[Depends(RateLimiter(times=10, minutes=1))])
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db), request: Request = None):
    start_time = time.time()
    try:
        user = get_user(db, username=form_data.username)
        if not user or not verify_password(form_data.password, user.hashed_password):
            logger.warning(f"Login failed: Invalid credentials for {form_data.username}", extra={"request_id": request.state.request_id if request else None, "username": form_data.username})
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.username}, expires_delta=access_token_expires
        )
        process_time = time.time() - start_time
        logger.info(f"User logged in successfully: {user.username}", extra={"request_id": request.state.request_id if request else None, "username": user.username, "process_time": process_time})
        return {"access_token": access_token, "token_type": "bearer"}
    except Exception as e:
        logger.error(f"Error during login: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "username": form_data.username})
        raise

@app.get("/users/me/", response_model=UserInDB)
async def read_users_me(current_user: models.User = Depends(get_current_active_user), request: Request = None):
    logger.info(f"Fetching user profile for {current_user.username}", extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id})
    return current_user

@app.put("/users/me/", response_model=UserInDB)
async def update_users_me(user_update: UserUpdate, current_user: models.User = Depends(get_current_active_user), db: Session = Depends(get_db), request: Request = None):
    start_time = time.time()
    try:
        if user_update.wallet_address:
            current_user.wallet_address = user_update.wallet_address
        db.add(current_user)
        db.commit()
        db.refresh(current_user)
        process_time = time.time() - start_time
        logger.info(f"User profile updated for {current_user.username}", extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id, "process_time": process_time})
        return current_user
    except Exception as e:
        logger.error(f"Error updating user profile for {current_user.username}: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id})
        raise

@app.post("/transactions/", response_model=TransactionInDB)
def create_transaction(transaction: TransactionCreate, current_user: models.User = Depends(get_current_active_user), db: Session = Depends(get_db), request: Request = None):
    start_time = time.time()
    try:
        db_transaction = models.Transaction(
            **transaction.dict(), owner_id=current_user.id, timestamp=datetime.utcnow()
        )
        db.add(db_transaction)
        db.commit()
        db.refresh(db_transaction)
        process_time = time.time() - start_time
        logger.info(f"Transaction recorded for user {current_user.username}", extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id, "transaction_id": db_transaction.id, "process_time": process_time})
        return db_transaction
    except Exception as e:
        logger.error(f"Error recording transaction for user {current_user.username}: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id})
        raise

@app.get("/transactions/me/", response_model=List[TransactionInDB])
def read_transactions_me(current_user: models.User = Depends(get_current_active_user), db: Session = Depends(get_db), request: Request = None):
    logger.info(f"Fetching transactions for user {current_user.username}", extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id})
    return current_user.transactions

@app.post("/kyc/submit/", response_model=KycStatusResponse)
def submit_kyc(kyc_submission: KycSubmission, current_user: models.User = Depends(get_current_active_user), db: Session = Depends(get_db), request: Request = None):
    start_time = time.time()
    try:
        if current_user.kyc_status != models.KycStatus.PENDING:
            logger.warning(f"KYC submission failed: User {current_user.username} KYC status is already {current_user.kyc_status.value}", extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id})
            raise HTTPException(status_code=400, detail=f"KYC status is already {current_user.kyc_status.value}")
        
        current_user.kyc_status = models.KycStatus.PENDING # Explicitly set to pending, though it's default
        db.add(current_user)
        db.commit()
        db.refresh(current_user)
        process_time = time.time() - start_time
        logger.info(f"KYC application submitted for user {current_user.username}", extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id, "process_time": process_time})
        return {"status": current_user.kyc_status, "message": "KYC application submitted for review."}
    except Exception as e:
        logger.error(f"Error submitting KYC for user {current_user.username}: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id})
        raise

@app.get("/kyc/status/", response_model=KycStatusResponse)
def get_kyc_status(current_user: models.User = Depends(get_current_active_user), request: Request = None):
    logger.info(f"Fetching KYC status for user {current_user.username}", extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id})
    return {"status": current_user.kyc_status, "message": f"Your KYC status is {current_user.kyc_status.value}."}

@app.post("/kyc/approve/{user_id}/", response_model=KycStatusResponse)
def approve_kyc(user_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_active_user), request: Request = None): # current_user for admin check
    start_time = time.time()
    try:
        # In a real app, you'd have proper admin role checking here
        if not current_user.is_active: # Placeholder for admin check
            logger.warning(f"Unauthorized attempt to approve KYC by user {current_user.username}", extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id})
            raise HTTPException(status_code=403, detail="Not authorized to perform this action")

        user_to_update = db.query(models.User).filter(models.User.id == user_id).first()
        if not user_to_update:
            logger.warning(f"KYC approval failed: User {user_id} not found", extra={"request_id": request.state.request_id if request else None, "admin_user_id": current_user.id, "target_user_id": user_id})
            raise HTTPException(status_code=404, detail="User not found")
        
        user_to_update.kyc_status = models.KycStatus.APPROVED
        user_to_update.kyc_verified = True # Update old field for compatibility
        db.add(user_to_update)
        db.commit()
        db.refresh(user_to_update)
        process_time = time.time() - start_time
        logger.info(f"KYC for user {user_id} approved by {current_user.username}", extra={"request_id": request.state.request_id if request else None, "admin_user_id": current_user.id, "target_user_id": user_id, "process_time": process_time})
        return {"status": user_to_update.kyc_status, "message": f"KYC for user {user_id} approved."}
    except Exception as e:
        logger.error(f"Error approving KYC for user {user_id}: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "admin_user_id": current_user.id, "target_user_id": user_id})
        raise

@app.post("/kyc/reject/{user_id}/", response_model=KycStatusResponse)
def reject_kyc(user_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_active_user), request: Request = None): # current_user for admin check
    start_time = time.time()
    try:
        # In a real app, you'd have proper admin role checking here
        if not current_user.is_active: # Placeholder for admin check
            logger.warning(f"Unauthorized attempt to reject KYC by user {current_user.username}", extra={"request_id": request.state.request_id if request else None, "user_id": current_user.id})
            raise HTTPException(status_code=403, detail="Not authorized to perform this action")

        user_to_update = db.query(models.User).filter(models.User.id == user_id).first()
        if not user_to_update:
            logger.warning(f"KYC rejection failed: User {user_id} not found", extra={"request_id": request.state.request_id if request else None, "admin_user_id": current_user.id, "target_user_id": user_id})
            raise HTTPException(status_code=404, detail="User not found")
        
        user_to_update.kyc_status = models.KycStatus.REJECTED
        user_to_update.kyc_verified = False # Update old field for compatibility
        db.add(user_to_update)
        db.commit()
        db.refresh(user_to_update)
        process_time = time.time() - start_time
        logger.info(f"KYC for user {user_id} rejected by {current_user.username}", extra={"request_id": request.state.request_id if request else None, "admin_user_id": current_user.id, "target_user_id": user_id, "process_time": process_time})
        return {"status": user_to_update.kyc_status, "message": f"KYC for user {user_id} rejected."}
    except Exception as e:
        logger.error(f"Error rejecting KYC for user {user_id}: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "admin_user_id": current_user.id, "target_user_id": user_id})
        raise

hyperliquid_client = HyperliquidClient()

@app.get("/hyperliquid/eth_price/")
def get_hyperliquid_eth_price(request: Request = None):
    start_time = time.time()
    try:
        price = hyperliquid_client.get_eth_price()
        if price is None:
            logger.error(f"Could not fetch ETH price from Hyperliquid.", extra={"request_id": request.state.request_id if request else None})
            raise HTTPException(status_code=500, detail="Could not fetch ETH price from Hyperliquid.")
        process_time = time.time() - start_time
        logger.info(f"Fetched ETH price: {price}", extra={"request_id": request.state.request_id if request else None, "eth_price": price, "process_time": process_time})
        return {"eth_price": price}
    except Exception as e:
        logger.error(f"Error fetching ETH price: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None})
        raise

@app.get("/hyperliquid/usdc_balance/")
def get_hyperliquid_usdc_balance(request: Request = None):
    start_time = time.time()
    try:
        balance = hyperliquid_client.get_usdc_balance()
        process_time = time.time() - start_time
        logger.info(f"Fetched USDC balance: {balance}", extra={"request_id": request.state.request_id if request else None, "usdc_balance": balance, "process_time": process_time})
        return {"usdc_balance": balance}
    except Exception as e:
        logger.error(f"Error fetching USDC balance: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None})
        raise

@app.get("/hyperliquid/funding_rate/")
def get_hyperliquid_funding_rate(coin: str = "ETH", request: Request = None):
    start_time = time.time()
    try:
        funding_rate = hyperliquid_client.get_funding_rate(coin)
        if funding_rate is None:
            logger.error(f"Could not fetch funding rate for {coin} from Hyperliquid.", extra={"request_id": request.state.request_id if request else None, "coin": coin})
            raise HTTPException(status_code=500, detail=f"Could not fetch funding rate for {coin} from Hyperliquid.")
        process_time = time.time() - start_time
        logger.info(f"Fetched funding rate for {coin}: {funding_rate}", extra={"request_id": request.state.request_id if request else None, "coin": coin, "funding_rate": funding_rate, "process_time": process_time})
        return {"funding_rate": funding_rate}
    except Exception as e:
        logger.error(f"Error fetching funding rate for {coin}: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "coin": coin})
        raise

@app.post("/hyperliquid/open_short_position/")
def open_hyperliquid_short_position(coin: str, size: float, request: Request = None):
    start_time = time.time()
    try:
        # This is a placeholder. Actual implementation would involve more parameters and error handling.
        hyperliquid_client.open_short_position(coin, size)
        process_time = time.time() - start_time
        logger.info(f"Attempted to open a short position for {size} {coin}.", extra={"request_id": request.state.request_id if request else None, "coin": coin, "size": size, "process_time": process_time})
        return {"message": f"Attempted to open a short position for {size} {coin}."}
    except Exception as e:
        logger.error(f"Error opening short position for {coin} with size {size}: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "coin": coin, "size": size})
        raise

@app.post("/hyperliquid/close_position/")
def close_hyperliquid_position(coin: str, request: Request = None):
    start_time = time.time()
    try:
        # This is a placeholder. Actual implementation would involve more parameters and error handling.
        hyperliquid_client.close_position(coin)
        process_time = time.time() - start_time
        logger.info(f"Attempted to close position for {coin}.", extra={"request_id": request.state.request_id if request else None, "coin": coin, "process_time": process_time})
        return {"message": f"Attempted to close position for {coin}."}
    except Exception as e:
        logger.error(f"Error closing position for {coin}: {e}", exc_info=True, extra={"request_id": request.state.request_id if request else None, "coin": coin})
        raise

@app.get("/")
def read_root():
    return {"message": "Hello World"}
