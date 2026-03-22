# on met la fonction qui est appelé dans controller

from app.models.user import User
from app.database import SessionLocal


def get_all_users():
    db = SessionLocal()
    try:
        return db.query(User).all()
    finally:
        db.close()