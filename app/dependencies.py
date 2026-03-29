from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
import os
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"

# HTTPBearer permet de coller directement le token dans Swagger (champ "Value")
bearer_scheme = HTTPBearer()


def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme)):
    token = credentials.credentials
    """Vérifie que le token est valide et retourne les données de l'utilisateur connecté."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])  # type: ignore[arg-type]
        user_id = payload.get("sub")
        role_id = payload.get("role_id")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Token invalide")
        return {"id": int(user_id), "email": payload.get("email"), "role_id": role_id}
    except JWTError:
        raise HTTPException(status_code=401, detail="Token invalide ou expiré")


def require_admin(current_user: dict = Depends(get_current_user)):
    """Vérifie que l'utilisateur connecté est un admin (role_id = 2)."""
    if current_user["role_id"] != 2:
        raise HTTPException(status_code=403, detail="Accès réservé aux administrateurs")
    return current_user


def require_user(current_user: dict = Depends(get_current_user)):
    """Vérifie que l'utilisateur est connecté, quel que soit son rôle."""
    return current_user
