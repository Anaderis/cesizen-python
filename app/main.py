from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from app.controllers.user_route import route as user_route
from app.controllers.login_route import route as login_route
from app.controllers.article_route import route as article_route
from app.controllers.activity_route import route as activity_route
from app.controllers.category_route import route as category_route
from app.controllers.log_route import route as log_route
import app.models.user  # noqa: F401 - enregistre les modèles SQLAlchemy
import app.models.content  # noqa: F401 - enregistre les modèles SQLAlchemy

app = FastAPI()

# Sert les fichiers statiques (PDFs, audios, vidéos) via /static/...
_static_dir = Path(__file__).resolve().parent / "static"
app.mount("/static", StaticFiles(directory=str(_static_dir)), name="static")

app.include_router(user_route, prefix="/api")
app.include_router(login_route, prefix="/api")
app.include_router(article_route, prefix="/api")
app.include_router(activity_route, prefix="/api")
app.include_router(category_route, prefix="/api")
app.include_router(log_route, prefix="/api")
