from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql://postgres:anais@localhost:5432/cesizen"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)