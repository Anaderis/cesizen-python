"""
conftest.py — Configuration partagée pour tous les tests.

- Crée une base de données SQLite en mémoire (isolée de la BDD PostgreSQL)
- Fournit un client HTTP pour les tests fonctionnels
- Fournit des tokens JWT pour simuler admin et utilisateur connecté
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from jose import jwt
from datetime import datetime, timedelta, timezone

from app.main import app as fastapi_app
from app.database import Base, SessionLocal
import app.models.user    # noqa: F401 — enregistre les modèles
import app.models.content  # noqa: F401 — enregistre les modèles
import os
from dotenv import load_dotenv

load_dotenv()


# ====================================================================================
#           CONFTEST : Génère une BDD de TEST avec SQLite + des tokens JWT           #
# ====================================================================================



# ========================
# BASE DE DONNÉES DE TEST
# ========================
# SQLite en mémoire : rapide, isolée, détruite après chaque session de tests
# Quand je lance pytest, il crée une base de données temporaire, crée les tables, 
# exécute les tests, puis détruit la base.

TEST_DATABASE_URL = "sqlite:///./test.db"

engine_test = create_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False}  # nécessaire pour SQLite
)
TestingSessionLocal = sessionmaker(bind=engine_test)


@pytest.fixture(scope="session", autouse=True)
def create_test_database():
    """Crée toutes les tables avant les tests, les supprime après."""
    Base.metadata.create_all(bind=engine_test)
    yield
    Base.metadata.drop_all(bind=engine_test)


# ========================
# CLIENT HTTP DE TEST
# ========================
# Pas besoin de lancer uvicorn, il simule les requêtes du CRUD dans le code de test.

@pytest.fixture(scope="session")
def client():
    """Client HTTP qui simule des appels à l'API sans lancer de serveur."""
    with TestClient(fastapi_app) as c:
        yield c


# ========================
# TOKENS JWT DE TEST
# ========================
# Plus besoin de faire un faux login pour avoir un token comme avec swagger
# les tokens ci-dessous sont utilisés
# dans les tests fonctionnels pour simuler un admin ou un utilisateur connecté.

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = "HS256"

# On a une fonction pour simuler chaque type d'utilisateur :
# On génère : un toen + 1 header pour chaque 

def make_token(user_id: int, role_id: int, email: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=60)
    return jwt.encode(
        {"sub": str(user_id), "email": email, "role_id": role_id, "exp": expire},
        SECRET_KEY,
        algorithm=ALGORITHM
    )


@pytest.fixture(scope="session")
def admin_token():
    """Token JWT valide pour un administrateur (role_id=2)."""
    return make_token(user_id=999, role_id=2, email="admin@test.fr")


@pytest.fixture(scope="session")
def user_token():
    """Token JWT valide pour un utilisateur standard (role_id=1)."""
    return make_token(user_id=998, role_id=1, email="user@test.fr")


@pytest.fixture(scope="session")
def admin_headers(admin_token):
    return {"Authorization": f"Bearer {admin_token}"}


@pytest.fixture(scope="session")
def user_headers(user_token):
    return {"Authorization": f"Bearer {user_token}"}
