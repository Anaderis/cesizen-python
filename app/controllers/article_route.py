from fastapi import APIRouter, HTTPException, Depends
from app.schemas.content_schema import ArticleUpdate, ArticleOut
from app.services.content_service import (
    get_all_articles, get_article_by_id, get_articles_by_category, update_article
)
from app.dependencies import require_admin

route = APIRouter(prefix="/articles", tags=["Articles"])

# Droits :
# - GET : public (tout le monde peut lire les articles)
# - PUT : admin uniquement (modification du contenu)
# Pas de CREATE ni DELETE : les articles sont gérés en base directement


# GET : Tous les articles → public
@route.get("/", response_model=list[ArticleOut])
def get_articles_endpoint():
    return get_all_articles()


# GET : Articles par catégorie → public
@route.get("/category/{category_id}", response_model=list[ArticleOut])
def get_articles_by_category_endpoint(category_id: int):
    return get_articles_by_category(category_id)


# GET : Article par ID → public
@route.get("/{id}", response_model=ArticleOut)
def get_article_endpoint(id: int):
    article = get_article_by_id(id)
    if not article:
        raise HTTPException(status_code=404, detail="Article non trouvé")
    return article


# PUT : Modifier un article → admin uniquement
@route.put("/{id}")
def update_article_endpoint(id: int, article: ArticleUpdate, _: dict = Depends(require_admin)):
    updated = update_article(id, article)
    if not updated:
        raise HTTPException(status_code=404, detail="Article non trouvé")
    return {"message": "Article modifié", "article": ArticleOut.model_validate(updated)}
