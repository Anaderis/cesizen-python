# on met la fonction qui est appelé dans controller

from app.models.user import User
from app.database import SessionLocal
import bcrypt
from jose import jwt
from datetime import datetime, timedelta, timezone
import os
from dotenv import load_dotenv

load_dotenv()

# Clé secrète chargée depuis le fichier .env (jamais en dur dans le code)
SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"
# Durée de validité du token : 60 minutes
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# LOGIN
# Principe du JWT en 5 étapes :
# 1. L'utilisateur envoie email + mot de passe
# 2. L'API vérifie le mot de passe avec bcrypt.checkpw() contre le hash stocké en base
# 3. Si ok → l'API génère un token JWT signé avec SECRET_KEY et le renvoie
# 4. Le front stocke ce token et l'envoie dans le header de chaque requête protégée
# 5. L'API vérifie le token à chaque appel pour identifier l'utilisateur
def login_user(email: str, password: str):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            return None
        # Étape 2 : vérification du mot de passe avec bcrypt
        if not bcrypt.checkpw(password.encode("utf-8"), user.password.encode("utf-8")):
            return None
        # Étape 3 : génération du token JWT avec l'id et l'email de l'utilisateur
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        token = jwt.encode({"sub": str(user.id), "email": user.email, "role_id": user.role_id, "exp": expire}, SECRET_KEY, algorithm=ALGORITHM)
        return token
    finally:
        db.close()


# GET : Tous les utilisateurs
def get_all_users():
    db = SessionLocal()
    try:
        # ici on récupère des objets Python (SQLAlchemy)
        return db.query(User).all()
    finally:
        db.close()

# GET : Utilisateur par ID
def get_user_by_id(user_id: int):
    db = SessionLocal()
    try:
        return db.query(User).filter(User.id == user_id).first()
    finally:
        db.close()


# POST : Créer un utilisateur
def create_user(user_data):
    db = SessionLocal()
    try:
        if db.query(User).filter(User.email == user_data.email).first():
            raise ValueError("Un compte existe déjà avec cette adresse e-mail.")

        #---gensalt--- : génère un sel (une chaîne de caractères) aléatoire pour le hashage du mot de passe
        #   si deux utilisateurs ont le même mot de passe, ils auront des hash différents grâce au sel unique
        #---hashpw--- : prend le mot de passe en clair et le sel pour produire un hash sécurisé.
        #---bcrypt--- travaille avec des bytes pas des strings, d'où l'encodage en utf-8 avant le hashage
        # et le décodage après pour stocker en string dans la DB.

        hashed_password = bcrypt.hashpw(user_data.password.encode("utf-8"), bcrypt.gensalt())

        new_user = User(
            name=user_data.name,
            surname=user_data.surname,
            email=user_data.email,
            password=hashed_password.decode("utf-8"),
            phone=user_data.phone,
            photo=user_data.photo,
            description=user_data.description,
            role_id=user_data.role_id
        )
        # add : remplit le formulaire pour la DB -> en attente
        db.add(new_user)
        # commit : envoies la requête INSERT
        db.commit()
        db.refresh(new_user)

        return new_user
    finally:
        db.close()


# DELETE : Supprimer un utilisateur
def delete_user(user_id: int):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return None
        db.delete(user)
        db.commit()
        return user
    finally:
        db.close()


# PUT : Modifier un utilisateur
def update_user(user_id: int, user_data):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return None

        # On ne met à jour que les champs envoyés (non None)
        fields = user_data.model_dump(exclude_none=True)
        if "password" in fields:
            fields["password"] = bcrypt.hashpw(fields["password"].encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        for field, value in fields.items():
            setattr(user, field, value)

        db.commit()
        db.refresh(user)
        return user
    finally:
        db.close()