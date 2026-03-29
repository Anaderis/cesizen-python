from fastapi import APIRouter, HTTPException
from app.schemas.user_schema import UserLogin
from app.services.user_service import login_user

route = APIRouter(prefix="/auth", tags=["Auth"])

# POST : Login utilisateur
# Étape 4 : le front récupère le token renvoyé ici et le stocke (localStorage ou cookie)
# Il devra l'envoyer dans le header "Authorization: Bearer <token>" pour les routes protégées
@route.post("/login")
def login_endpoint(credentials: UserLogin):
    token = login_user(credentials.email, credentials.password)
    if not token:
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")
    return {"message": "Connexion réussie", "access_token": token, "token_type": "bearer"}
