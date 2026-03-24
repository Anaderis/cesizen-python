from fastapi import APIRouter
from app.database import SessionLocal
from app.models.content import User

route = APIRouter()

@route.get("/users")
def get_users():
    db = SessionLocal()
    users = db.query(User).all()
    db.close()
    return users