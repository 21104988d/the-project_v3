from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime
from .database.models import KycStatus

class UserBase(BaseModel):
    email: EmailStr
    username: str

class UserCreate(UserBase):
    password: str

class UserInDB(UserBase):
    id: int
    hashed_password: str
    is_active: bool
    kyc_verified: bool
    kyc_status: KycStatus
    wallet_address: Optional[str] = None

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class UserUpdate(BaseModel):
    wallet_address: Optional[str] = None

class TransactionBase(BaseModel):
    sender_address: str
    receiver_address: str
    amount_usdc: float
    on_chain_tx_hash: str

class TransactionCreate(TransactionBase):
    pass

class TransactionInDB(TransactionBase):
    id: int
    timestamp: datetime
    owner_id: int

    class Config:
        from_attributes = True

class KycSubmission(BaseModel):
    # In a real scenario, this would contain actual KYC data like ID documents, etc.
    # For this generic integration, we'll just use a placeholder.
    message: str = "Submitting KYC application"

class KycStatusResponse(BaseModel):
    status: KycStatus
    message: str
