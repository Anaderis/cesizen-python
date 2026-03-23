from fastapi import APIRouter
from app.schemas.user_schema import UserSchema
from app.services.user_service import get_all_users
from app.services.user_service import create_user



route = APIRouter(prefix="/users", tags=["Users"])

# GET : Tous les utilisateurs
@route.get("/", response_model=list[UserSchema])
def get_users_endpoint():
    return get_all_users()

# GET : Utilisateur par ID
@route.get("/{id}")
def get_user_id_endpoint(id : int):
    return {"user_id" : id}

# POST : Créer un utilisateur
@route.post("/create")
def create_user_endpoint(user : UserSchema):
    return create_user(user)