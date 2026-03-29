from pydantic import BaseModel, ConfigDict, field_validator
import re


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

    @field_validator("name", "surname")
    def not_empty(cls, value):
        if not value.strip():
            raise ValueError("Ce champ ne peut pas être vide")
        return value.strip()

    @field_validator("email")
    def valid_email(cls, value):
        if not re.match(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$", value):
            raise ValueError("Format d'email invalide")
        return value.lower().strip()

    @field_validator("password")
    def strong_password(cls, value):
        if len(value) < 5:
            raise ValueError("Le mot de passe doit faire au moins 5 caractères")
        if not re.search(r"[A-Z]", value):
            raise ValueError("Le mot de passe doit contenir au moins une majuscule")
        if not re.search(r"\d", value):
            raise ValueError("Le mot de passe doit contenir au moins un chiffre")
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", value):
            raise ValueError("Le mot de passe doit contenir au moins un caractère spécial")
        return value


# Schema pour le login (POST) - uniquement email et mot de passe
class UserLogin(BaseModel):
    email: str
    password: str


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
    is_active: bool | None = None

    # Chaque validateur commence par if value is None: return value, 
    # ce qui laisse passer les champs non fournis sans validation. 
    # Seuls les champs effectivement envoyés par l'utilisateur sont vérifiés.

    @field_validator("name", "surname")
    def not_empty(cls, value):
        if value is None:
            return value
        if not value.strip():
            raise ValueError("Ce champ ne peut pas être vide")
        return value.strip()

    @field_validator("email")
    def valid_email(cls, value):
        if value is None:
            return value
        if not re.match(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$", value):
            raise ValueError("Format d'email invalide")
        return value.lower().strip()

    @field_validator("password")
    def strong_password(cls, value):
        if value is None:
            return value
        if len(value) < 5:
            raise ValueError("Le mot de passe doit faire au moins 5 caractères")
        if not re.search(r"[A-Z]", value):
            raise ValueError("Le mot de passe doit contenir au moins une majuscule")
        if not re.search(r"\d", value):
            raise ValueError("Le mot de passe doit contenir au moins un chiffre")
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", value):
            raise ValueError("Le mot de passe doit contenir au moins un caractère spécial")
        return value


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
    is_active: bool = True

    model_config = ConfigDict(from_attributes=True)