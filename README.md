# CESIZen — Backend API

Backend d'une application de bien-être mental développée dans le cadre d'un projet scolaire à CESI. L'application permet aux utilisateurs de consulter des articles sur la santé mentale, d'accéder à des activités de détente, et de gérer leur compte personnel.

---

## Fonctionnalités

- Authentification JWT avec gestion des rôles (utilisateur / administrateur)
- Gestion des comptes utilisateurs (création, modification, désactivation, suppression)
- Consultation d'articles sur la santé mentale
- Activités de détente avec système de favoris
- Back office administrateur (gestion du contenu, activation/désactivation)
- Pipeline CI/CD avec tests automatisés sur chaque Pull Request

---

## Stack technique

| Couche | Technologie |
|---|---|
| Langage | Python 3.11 |
| Framework API | FastAPI |
| ORM | SQLAlchemy |
| Base de données | PostgreSQL |
| Authentification | JWT (python-jose) + bcrypt |
| Validation | Pydantic v2 |
| Tests | pytest + httpx |
| CI/CD | GitHub Actions |

---

## Architecture

Le projet suit une architecture **MVC** :

```
app/
  controllers/   ← routes HTTP (FastAPI)
  services/      ← logique métier
  models/        ← modèles SQLAlchemy (BDD)
  schemas/       ← validation des données (Pydantic)
  dependencies.py← gestion de l'authentification JWT
  database.py    ← connexion PostgreSQL
tests/
  unit/          ← tests des validateurs et services (sans BDD)
  functional/    ← tests des endpoints HTTP (droits d'accès, réponses)
```

---

## Endpoints principaux

### Authentification
| Méthode | Route | Accès |
|---|---|---|
| POST | `/api/auth/login` | Public |

### Utilisateurs
| Méthode | Route | Accès |
|---|---|---|
| GET | `/api/users/` | Admin |
| POST | `/api/users/create` | Public |
| PUT | `/api/users/{id}` | Propriétaire ou Admin |
| PUT | `/api/users/deactivate/{id}` | Propriétaire ou Admin |
| DELETE | `/api/users/{id}` | Propriétaire ou Admin |
| GET | `/api/users/me/favorites` | Utilisateur connecté |

### Articles santé mentale
| Méthode | Route | Accès |
|---|---|---|
| GET | `/api/articles/` | Public |
| GET | `/api/articles/{id}` | Public |
| PUT | `/api/articles/{id}` | Admin |

### Activités de détente
| Méthode | Route | Accès |
|---|---|---|
| GET | `/api/activities/` | Public |
| GET | `/api/activities/{id}` | Public |
| POST | `/api/activities/create` | Admin |
| PUT | `/api/activities/{id}` | Admin |
| PUT | `/api/activities/deactivate/{id}` | Admin |
| POST | `/api/activities/{id}/favorite` | Utilisateur connecté |
| DELETE | `/api/activities/{id}/favorite` | Utilisateur connecté |

---

## Tests

39 tests couvrant :
- Validation des données (schémas Pydantic)
- Hachage des mots de passe (bcrypt)
- Authentification JWT
- Droits d'accès sur chaque endpoint (admin, utilisateur, public)
- Respect du cahier des charges (routes inexistantes = 405)

```bash
python -m pytest tests/ -v
```

---

## Installation locale

```bash
# Cloner le repo
git clone https://github.com/Anaderis/cesizen-python.git
cd cesizen-python

# Créer l'environnement virtuel
python -m venv venv
source venv/bin/activate  # Windows : venv\Scripts\activate

# Installer les dépendances
pip install -r requirements.txt

# Créer le fichier .env
echo "SECRET_KEY=votre_cle_secrete" > .env

# Lancer le serveur
python -m uvicorn app.main:app --reload
```

> La base de données PostgreSQL doit être configurée dans `app/database.py`

---

## CI/CD

Chaque Pull Request vers `main` déclenche automatiquement les tests via **GitHub Actions**. Le merge est bloqué si un test échoue.
