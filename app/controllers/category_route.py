from fastapi import APIRouter
from app.schemas.content_schema import CategoryOut, FormatOut
from app.services.content_service import get_all_categories, get_all_formats

route = APIRouter(prefix="/categories", tags=["Categories"])


# GET : Toutes les catégories → public
@route.get("/", response_model=list[CategoryOut])
def get_categories_endpoint():
    return get_all_categories()


# GET : Tous les formats → public
@route.get("/formats", response_model=list[FormatOut])
def get_formats_endpoint():
    return get_all_formats()
