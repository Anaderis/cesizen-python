from sqlalchemy import Column, Integer, String, Text, Boolean, Date, TIMESTAMP, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


# ========================
# ROLE
# ========================
class Role(Base):
    __tablename__ = "role"

    id = Column(Integer, primary_key=True, index=True)
    type = Column(String(100), unique=True, nullable=False)

    user = relationship("User", back_populates="role")

# ========================
# USER
# ========================
class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    surname = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    phone = Column(String(20))
    photo = Column(String(255))
    description = Column(Text)
    role_id = Column(Integer, ForeignKey("role.id"), nullable=False)
    is_active = Column(Boolean, default=True)

    created_at = Column(TIMESTAMP, default=datetime.utcnow)
    updated_at = Column(TIMESTAMP)

    role = relationship("Role", back_populates="user")
    favorites = relationship("Favorites", back_populates="user")
    logs = relationship("Log", back_populates="user")


# ========================
# LOG
# ========================
class Log(Base):
    __tablename__ = "log"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    action = Column(String(100), nullable=False)
    description = Column(Text)
    date_action = Column(TIMESTAMP, default=datetime.utcnow)

    user = relationship("User", back_populates="logs")