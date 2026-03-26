from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError

SECRET_KEY = "cesizen_secret_key"
ALGORITHM = "HS256"

# Indique à FastAPI où trouver le token (dans le header Authorization: Bearer <token>)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


def get_current_user(token: str = Depends(oauth2_scheme)):
    """Vérifie que le token est valide et retourne les données de l'utilisateur connecté."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
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
