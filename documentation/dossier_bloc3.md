# Dossier Bloc 3 — Déployer et sécuriser les applications informatiques
**CESIZen — Application de bien-être mental**
**Anaïs Kajjaj — CDA 2023/2024**

---

## Sommaire

1. [Présentation du projet](#1-présentation-du-projet)
2. [Plan de déploiement](#2-plan-de-déploiement)
   - 2.1 Architecture générale
   - 2.2 Environnements Docker
   - 2.3 Versioning
   - 2.4 Pipeline CI/CD
3. [Plan de maintenance](#3-plan-de-maintenance)
   - 3.1 Outil de gestion des tickets
   - 3.2 Méthodologie de gestion des corrections et évolutions
   - 3.3 Veille technologique
4. [Plan de sécurisation](#4-plan-de-sécurisation)
   - 4.1 Analyse des vulnérabilités et risques
   - 4.2 Actions correctives et préventives
   - 4.3 Données personnelles et RGPD
   - 4.4 Gestion de crise
   - 4.5 Bonnes pratiques de développement

---

## 1. Présentation du projet

CESIZen est une application web de bien-être mental développée dans le cadre du titre **Concepteur Développeur d'Applications** à CESI. Elle propose à ses utilisateurs des outils pour mieux gérer leur stress au quotidien : articles de santé mentale, activités de détente, et gestion de compte personnalisée.

### Stack technique

| Couche | Technologie |
|---|---|
| Backend | Python 3.11 / FastAPI |
| Frontend | Vue 3 / Vite |
| Base de données | PostgreSQL |
| ORM | SQLAlchemy |
| Authentification | JWT (python-jose) + bcrypt |
| Tests | pytest |
| Conteneurisation | Docker / Docker Compose |
| Versioning | Git / GitHub |
| CI/CD | GitHub Actions |

### Acteurs

| Acteur | Rôle |
|---|---|
| Visiteur anonyme | Consultation des articles et activités |
| Utilisateur connecté | Gestion du compte, favoris |
| Administrateur | Gestion du contenu, des utilisateurs et de la configuration |

---

## 2. Plan de déploiement

### 2.1 Architecture générale

L'application repose sur trois services containerisés qui communiquent via un réseau Docker interne :

- **Backend** : API FastAPI servie par Uvicorn en développement, Gunicorn en production
- **Frontend** : application Vue 3 servie par le serveur Vite en développement, compilée et servie par Nginx en staging et production
- **Base de données** : PostgreSQL avec un volume Docker dédié par environnement

```
  Navigateur
      │
      ▼
  Nginx :80  ──────────────────────────────────┐
      │                                         │
      ├── /api/*  ──►  Backend :8000            │
      │                     │                   │
      │              PostgreSQL :5432            │
      │                                         │
      └── /*  ──►  Fichiers statiques Vue       │
                                                 │
                        Réseau Docker interne ───┘
```

Le projet suit une stratégie de branches à quatre niveaux, chacun associé à un environnement distinct :

| Branche | Environnement | Usage |
|---|---|---|
| `{id}-nom-issue` | Développement | Travail sur une feature en local |
| `dev` | Développement partagé | Intégration des features avant staging |
| `stage` | Staging | Validation avant mise en production |
| `main` | Production | Application en ligne |

---

### 2.2 Environnements Docker

Tous les fichiers Docker sont regroupés dans le dossier `docker/` à la racine du projet :

```
docker/
  Dockerfile              ← image backend (Python 3.11 + dépendances pip)
  Dockerfile.frontend     ← image frontend multi-stage (build Node → Nginx)
  nginx.conf              ← configuration Nginx (proxy /api et /static → backend)
  docker-compose.dev.yml
  docker-compose.stage.yml
  docker-compose.prod.yml
```

Les credentials de la base de données ne sont jamais écrits en dur dans les fichiers Compose. Les variables sont lues depuis un fichier `.env` non commité, propre à chaque environnement :

| Environnement | Fichier | Commande de démarrage |
|---|---|---|
| Dev | `.env` | `docker compose -f docker/docker-compose.dev.yml up -d` |
| Staging | `.env.stage` | `docker compose -f docker/docker-compose.stage.yml --env-file .env.stage up -d` |
| Production | `.env.prod` | `docker compose -f docker/docker-compose.prod.yml --env-file .env.prod up -d` |

#### Environnement de développement

Utilisé au quotidien sur les branches issues. Le code source est monté en **volume** dans le container backend — toute modification de fichier Python est visible instantanément sans rebuild. Uvicorn tourne avec `--reload`. Le frontend utilise le serveur Vite avec hot reload.

| Service | Image | Port exposé | Particularités |
|---|---|---|---|
| `db` | postgres:16-alpine | 5432 | Volume `pgdata_dev`, healthcheck |
| `backend` | Dockerfile local | 8000 | `--reload`, volume mount du code |
| `frontend` | node:20-alpine | 5173 | Vite dev server, hot reload |

#### Environnement de staging

Utilisé sur la branche `stage`. Les images sont buildées depuis le code source — aucun volume mount. On teste le binaire réel tel qu'il sera livré. Le frontend est compilé (`npm run build`) puis servi par Nginx. La base de données est isolée de la production (`cesizen_stage`).

| Service | Image | Port exposé | Particularités |
|---|---|---|---|
| `db` | postgres:16-alpine | — | Volume `pgdata_stage` isolé |
| `backend` | Dockerfile buildé | 8000 | Sans --reload, image figée |
| `frontend` | Dockerfile.frontend | 80 | Nginx + proxy /api → backend |

#### Environnement de production

Utilisé sur la branche `main`. Le backend est lancé avec **Gunicorn** et deux workers Uvicorn pour absorber la charge et résister aux crashs. Tous les services redémarrent automatiquement (`restart: unless-stopped`). Seul le port 80 (Nginx) est exposé — la base de données et le backend ne sont pas accessibles depuis l'extérieur.

| Service | Image | Port exposé | Particularités |
|---|---|---|---|
| `db` | postgres:16-alpine | — | Volume `pgdata_prod`, credentials sécurisés |
| `backend` | Dockerfile buildé | — | Gunicorn 2 workers, restart automatique |
| `frontend` | Dockerfile.frontend | 80 | Nginx reverse proxy, restart automatique |

---

### 2.3 Versioning

<!-- À rédiger après validation du système de versioning -->

---

### 2.4 Pipeline CI/CD

Le pipeline est géré via **GitHub Actions** avec trois workflows distincts, un par cible de merge.

#### Déclenchement par environnement

```
Branche issue  ──PR──►  dev    →  ci.yml         (tests pytest)
dev            ──PR──►  stage  →  ci-stage.yml   (tests + build Docker + containers)
stage          ──PR──►  main   →  docker-publish.yml  (tests + build + publish image)
```

#### `ci.yml` — PR vers `dev`

Déclenché à chaque Pull Request ciblant la branche `dev`. Bloque le merge si un test échoue.

| Étape | Action |
|---|---|
| 1 | Checkout du code |
| 2 | Installation Python 3.11 + dépendances |
| 3 | Création du fichier `.env` avec les secrets GitHub |
| 4 | Lancement des tests pytest |

#### `ci-stage.yml` — PR vers `stage`

Déclenché à chaque Pull Request ciblant la branche `stage`. Vérifie les tests et que les containers démarrent correctement.

| Étape | Action |
|---|---|
| 1 | Tests pytest (même logique que ci.yml) |
| 2 | Build des images Docker backend et frontend |
| 3 | Démarrage des trois containers via `docker-compose.stage.yml` |
| 4 | Vérification que le backend répond sur `/docs` |
| 5 | Affichage de l'état des containers (même en cas d'échec) |

#### `docker-publish.yml` — Push vers `main`

Déclenché à chaque merge sur `main`. Publie l'image Docker sur le **GitHub Container Registry** (`ghcr.io`).

| Étape | Action |
|---|---|
| 1 | Tests pytest (filet de sécurité avant publication) |
| 2 | Authentification sur ghcr.io avec le token GitHub |
| 3 | Build et push de l'image avec deux tags : `:latest` et `:sha-du-commit` |

Le double tag permet de toujours avoir accès à la dernière version stable (`:latest`) tout en gardant un historique des images par commit (`:abc1234`), utile pour un rollback rapide en cas de problème en production.

---

## 3. Plan de maintenance

### 3.1 Outil de gestion des tickets

<!-- À rédiger après validation de l'outil de ticketing -->

### 3.2 Méthodologie de gestion des corrections et évolutions

<!-- À rédiger après validation de la méthodologie -->

### 3.3 Veille technologique

<!-- À rédiger après validation de la méthodologie de veille -->

---

## 4. Plan de sécurisation

### 4.1 Analyse des vulnérabilités et risques

<!-- À rédiger après validation du plan de sécurisation -->

### 4.2 Actions correctives et préventives

<!-- À rédiger après validation du plan de sécurisation -->

### 4.3 Données personnelles et RGPD

<!-- À rédiger après validation du plan RGPD -->

### 4.4 Gestion de crise

<!-- À rédiger après validation de la méthodologie de gestion de crise -->

### 4.5 Bonnes pratiques de développement

<!-- À rédiger après validation des bonnes pratiques -->
