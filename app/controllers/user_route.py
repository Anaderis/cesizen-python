from fastapi import APIRouter, HTTPException, Depends
from app.schemas.user_schema import UserCreate, UserOut, UserUpdate
from app.services.user_service import get_all_users, get_user_by_id, create_user, update_user, delete_user
from app.dependencies import require_admin, require_user

route = APIRouter(prefix="/users", tags=["Users"])

# GET : Tous les utilisateurs → admin uniquement
@route.get("/", response_model=list[UserOut])
def get_users_endpoint(_: dict = Depends(require_admin)):
    return get_all_users()

# GET : Utilisateur par ID → utilisateur connecté (son propre compte) ou admin
@route.get("/{id}", response_model=UserOut)
def get_user_id_endpoint(id: int, current_user: dict = Depends(require_user)):
    if current_user["role_id"] != 2 and current_user["id"] != id:
        raise HTTPException(status_code=403, detail="Accès non autorisé")
    user = get_user_by_id(id)
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return user

# POST : Créer un utilisateur → public (pas de Depends)
@route.post("/create")
def create_user_endpoint(user: UserCreate):
    created = create_user(user)
    return {"message": "Utilisateur créé", "user": UserOut.model_validate(created)}

# PUT : Modifier un utilisateur → utilisateur connecté (son propre compte) ou admin
@route.put("/{id}")
def update_user_endpoint(id: int, user: UserUpdate, current_user: dict = Depends(require_user)):
    if current_user["role_id"] != 2 and current_user["id"] != id:
        raise HTTPException(status_code=403, detail="Accès non autorisé")
    updated = update_user(id, user)
    if not updated:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return {"message": "Utilisateur modifié", "user": UserOut.model_validate(updated)}

# PUT : Désactiver un utilisateur → admin uniquement
@route.put("/deactivate/{id}")
def deactivate_user_endpoint(id: int, _: dict = Depends(require_admin)):
    deactivate = update_user(id, UserUpdate(is_active=False))
    if not deactivate:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return {"message": "Utilisateur désactivé", "user": UserOut.model_validate(deactivate)}

# DELETE : Supprimer un utilisateur → admin uniquement
@route.delete("/{id}")
def delete_user_endpoint(id: int, _: dict = Depends(require_admin)):
    deleted = delete_user(id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    return {"message": "Utilisateur supprimé"}
