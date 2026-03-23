# on met la fonction qui est appelé dans controller

from app.models.user import User
from app.database import SessionLocal


def get_all_users():
    db = SessionLocal()
    try:
        # ici on récupère des objets Python (SQLAlchemy)
        return db.query(User).all()
    finally:
        db.close()

# POST : Créer un utilisateur

def create_user(user_data):
    db = SessionLocal()
    try:
        new_user = User(
            name=user_data.name,
            surname=user_data.surname,
            email=user_data.email,
            password=user_data.password,
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