from pydantic import BaseModel


# Schema pour la création d'un utilisateur (POST) - inclut le mot de passe
class UserCreate(BaseModel):
    name: str
    surname: str
    email: str
    password: str
    phone: str | None = None
    photo: str | None = None
    description: str | None = None
    role_id: int = 1


# Schema pour la modification d'un utilisateur (PUT) - tous les champs optionnels
class UserUpdate(BaseModel):
    name: str | None = None
    surname: str | None = None
    email: str | None = None
    password: str | None = None
    phone: str | None = None
    photo: str | None = None
    description: str | None = None
    role_id: int | None = None


# Schema pour les réponses (GET) - exclut le mot de passe
class UserOut(BaseModel):
    id: int
    name: str
    surname: str
    email: str
    phone: str | None = None
    photo: str | None = None
    description: str | None = None
    role_id: int

    class Config:
        from_attributes = True