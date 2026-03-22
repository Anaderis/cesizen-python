from fastapi import APIRouter
from app.schemas.user_schema import UserSchema
from app.services.user_service import get_all_users



route = APIRouter(prefix="/users", tags=["Users"])


@route.get("/", response_model=list[UserSchema])
def get_users():
    return get_all_users()

@route.post("/")
def create_user(user : UserSchema):
    return user