from pydantic import BaseModel, ConfigDict, field_validator
from datetime import date

#from_attributes est utilisé pour permettre la conversion d'instances de classes ORM 
# (comme celles de SQLAlchemy) en modèles Pydantic, qui utilise BaseModel.
# Cela permet de retourner directement les objets SQLAlchemy dans les endpoints FastAPI
# sans avoir à les convertir manuellement en dictionnaires ou en modèles Pydantic.

# ========================
# CATEGORY
# ========================
class CategoryOut(BaseModel):
    id: int
    name: str

    model_config = ConfigDict(from_attributes=True)


# ========================
# FORMAT
# ========================
class FormatOut(BaseModel):
    id: int
    type: str

    model_config = ConfigDict(from_attributes=True)


# ========================
# ARTICLE SANTE
# ========================
class ArticleCreate(BaseModel):
    title: str
    description: str | None = None   # courte accroche
    content: str | None = None        # contenu HTML complet
    publish_date: date | None = None
    active: bool = True
    category_id: int

    @field_validator("title")
    def not_empty(cls, value):
        if not value.strip():
            raise ValueError("Le titre ne peut pas être vide")
        return value.strip()


class ArticleUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    content: str | None = None
    publish_date: date | None = None
    active: bool | None = None
    category_id: int | None = None

    @field_validator("title")
    def not_empty(cls, value):
        if value is None:
            return value
        if not value.strip():
            raise ValueError("Le titre ne peut pas être vide")
        return value.strip()


class ArticleOut(BaseModel):
    id: int
    title: str
    description: str | None = None
    content: str | None = None
    publish_date: date | None = None
    active: bool
    category_id: int
    category: CategoryOut | None = None

    model_config = ConfigDict(from_attributes=True)


# ========================
# ACTIVITY
# ========================
class ActivityCreate(BaseModel):
    title: str
    description: str | None = None
    url: str | None = None
    duration: str | None = None
    active: bool = True
    category_id: int
    format_id: int

    @field_validator("title")
    def not_empty(cls, value):
        if not value.strip():
            raise ValueError("Le titre ne peut pas être vide")
        return value.strip()


class ActivityUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    url: str | None = None
    duration: str | None = None
    active: bool | None = None
    category_id: int | None = None
    format_id: int | None = None

    @field_validator("title")
    def not_empty(cls, value):
        if value is None:
            return value
        if not value.strip():
            raise ValueError("Le titre ne peut pas être vide")
        return value.strip()


class ActivityOut(BaseModel):
    id: int
    title: str
    description: str | None = None
    url: str | None = None
    duration: str | None = None
    active: bool
    category_id: int
    format_id: int
    category: CategoryOut | None = None
    format: FormatOut | None = None

    model_config = ConfigDict(from_attributes=True)
