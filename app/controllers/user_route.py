from fastapi import APIRouter, HTTPException
from app.schemas.user_schema import UserCreate, UserOut, UserUpdate
from app.services.user_service import get_all_users, create_user, update_user


route = APIRouter(prefix="/users", tags=["Users"])

# GET : Tous les utilisateurs
@route.get("/", response_model=list[UserOut])
def get_users_endpoint():
    return get_all_users()

# GET : Utilisateur par ID
@route.get("/{id}")
def get_user_id_endpoint(id: int):
    return {"user_id": id}

# POST : Créer un utilisateur
@route.post("/create", response_model=UserOut)
def create_user_endpoint(user: UserCreate):
    return create_user(user)

# PUT : Modifier un utilisateur
# User out est un modèle qui exclut le mot de passe, on ne veut pas le renvoyer dans la réponse
@route.put("/{id}", response_model=UserOut)
def update_user_endpoint(id: int, user: UserUpdate):
    updated = update_user(id, user)
    if not updated:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return updated

# TO DO : PUT : Désactiver un utilisateur (is_active = False)
# pour désactiver le compte utilisateur, on peut faire une route PUT qui met à jour 
# un champ "is_active" à False
@route.put("{id}/deactivate", response_model=UserOut)
def deactivate_user_endpoint(id: int):
    deactivate = update_user(id, UserUpdate(is_active=False))
    if not deactivate:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return deactivate

# TO DO : DELETE : Supprimer un utilisateur





