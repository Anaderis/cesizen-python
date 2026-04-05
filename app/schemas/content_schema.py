from pydantic import BaseModel, ConfigDict, field_validator
from datetime import date
import os

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
    photo: str | None = None
    publish_date: date | None = None
    active: bool
    category_id: int
    category: CategoryOut | None = None

    model_config = ConfigDict(from_attributes=True)


# ========================
# ACTIVITY
# ========================
def _validate_activity_url(value: str | None) -> str | None:
    """URL externe (https://…) ou chemin de fichier statique (/static/… avec extension)."""
    if value is None or value.strip() == '':
        return None
    url = value.strip()
    if url.startswith('http://') or url.startswith('https://'):
        return url
    if url.startswith('/static/') and os.path.splitext(url)[1]:
        return url
    raise ValueError(
        "L'URL doit être une adresse web (https://…) "
        "ou un chemin de fichier statique avec extension (ex : /static/pdf/fichier.pdf)"
    )


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

    @field_validator("url")
    def valid_url(cls, value):
        return _validate_activity_url(value)


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

    @field_validator("url")
    def valid_url(cls, value):
        return _validate_activity_url(value)


class ActivityOut(BaseModel):
    id: int
    title: str
    description: str | None = None
    url: str | None = None
    photo: str | None = None
    duration: str | None = None
    active: bool
    category_id: int
    format_id: int
    category: CategoryOut | None = None
    format: FormatOut | None = None

    model_config = ConfigDict(from_attributes=True)
