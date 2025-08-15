from sqlalchemy import Boolean, Column, Integer, String, DateTime, Float, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy import Enum as SQLEnum
from enum import Enum

class KycStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)
    kyc_verified = Column(Boolean, default=False) # Keep for now, might be removed later
    kyc_status = Column(SQLEnum(KycStatus), default=KycStatus.PENDING)
    wallet_address = Column(String, unique=True, index=True, nullable=True)

    transactions = relationship("Transaction", back_populates="owner")

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    sender_address = Column(String, index=True)
    receiver_address = Column(String, index=True)
    amount_usdc = Column(Float)
    timestamp = Column(DateTime)
    on_chain_tx_hash = Column(String, unique=True, index=True)
    
    owner_id = Column(Integer, ForeignKey("users.id"))
    owner = relationship("User", back_populates="transactions")
