from fastapi import FastAPI
from app.controllers.user_route import route as user_route
from app.controllers.login_route import route as login_route
import app.models.user  # noqa: F401 - enregistre les modèles SQLAlchemy
import app.models.content  # noqa: F401 - enregistre les modèles SQLAlchemy

app = FastAPI()
app.include_router(user_route, prefix="/api")
app.include_router(login_route, prefix="/api")