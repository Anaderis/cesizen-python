# Mémo commandes — CESIZen

---

## Environnement virtuel Python

```bash
# Créer l'environnement virtuel
python -m venv pythonCesizen

# Activer (PowerShell)
.\pythonCesizen\Scripts\Activate.ps1

# Désactiver
deactivate

# Installer les dépendances
pip install -r requirements.txt

# Sauvegarder les dépendances après un pip install
pip freeze > requirements.txt
```

---

## Lancer l'API en local (sans Docker)

```bash
uvicorn app.main:app --reload
# ou
python -m uvicorn app.main:app --reload
```

---

## BDD

Remettre la BDD
docker exec -i docker-db-1 psql -U postgres -d cesizen_dev -f /dev/stdin < app/static/sql/cesizen-0104.sql


## Docker — Ports par environnement
    
| Environnement | Frontend | Backend / API | Base de données |
|---|---|---|---|
| Dev | http://localhost:5173 | http://localhost:8000 | localhost:5433 (PostgreSQL) |
| Staging | http://localhost:80 | http://localhost:8000 | non exposée |
| Production | http://localhost:80 | http://localhost:8000 | non exposée |

Docs API (Swagger) : http://localhost:8000/docs

---

## Docker — Environnement de développement

```bash
# Démarrer
docker compose -f docker/docker-compose.dev.yml up -d

# Démarrer et rebuilder les images
docker compose -f docker/docker-compose.dev.yml up -d --build

# Arrêter (garde les volumes / données)
docker compose -f docker/docker-compose.dev.yml down

# Arrêter et supprimer les volumes (repart de zéro)
docker compose -f docker/docker-compose.dev.yml down -v

# Voir l'état des containers
docker compose -f docker/docker-compose.dev.yml ps

# Voir les logs du backend
docker compose -f docker/docker-compose.dev.yml logs backend

# Voir les logs en temps réel
docker compose -f docker/docker-compose.dev.yml logs -f backend
```

---

## Docker — Environnement de staging

```bash
# Démarrer et rebuilder
docker compose -f docker/docker-compose.stage.yml --env-file .env.stage up -d --build

# Arrêter (garde les données)
docker compose -f docker/docker-compose.stage.yml down
# ⚠️ Ne JAMAIS faire down -v en staging ou production — cela supprime toutes les données


# Voir l'état des containers
docker compose -f docker/docker-compose.stage.yml ps

# Voir les logs du backend
docker compose -f docker/docker-compose.stage.yml logs backend
docker compose -f docker/docker-compose.stage.yml logs -f backend
```

---

## Docker — Environnement de production

```bash
# Démarrer et rebuilder
docker compose -f docker/docker-compose.prod.yml --env-file .env.prod up -d --build

# Arrêter (garde les données)
docker compose -f docker/docker-compose.prod.yml down
# ⚠️ Ne JAMAIS faire down -v en staging ou production — cela supprime toutes les données


# Voir les logs du backend
docker compose -f docker/docker-compose.prod.yml logs backend
docker compose -f docker/docker-compose.prod.yml logs -f backend
```

---

## Base de données — Import du fichier SQL (première fois)

A faire une seule fois par environnement pour importer les données initiales.
Si la base existe déjà, sauter le CREATE DATABASE.

**Dev :**
```bash
docker compose -f docker/docker-compose.dev.yml exec db psql -U postgres -c "CREATE DATABASE cesizen_dev;"
docker compose -f docker/docker-compose.dev.yml cp app/static/sql/cesizen-0104.sql db:/cesizen-0104.sql
docker compose -f docker/docker-compose.dev.yml exec db psql -U postgres -d cesizen_dev -f /cesizen-0104.sql
```

**Staging :**
```bash
docker compose -f docker/docker-compose.stage.yml exec db psql -U postgres -c "CREATE DATABASE cesizen_stage;"
docker compose -f docker/docker-compose.stage.yml cp app/static/sql/cesizen-0104.sql db:/cesizen-0104.sql
docker compose -f docker/docker-compose.stage.yml exec db psql -U postgres -d cesizen_stage -f /cesizen-0104.sql
```

**Production :**
```bash
docker compose -f docker/docker-compose.prod.yml exec db psql -U postgres -c "CREATE DATABASE cesizen_prod;"
docker compose -f docker/docker-compose.prod.yml cp app/static/sql/cesizen-0104.sql db:/cesizen-0104.sql
docker compose -f docker/docker-compose.prod.yml exec db psql -U postgres -d cesizen_prod -f /cesizen-0104.sql
```

---

## Base de données — Requêtes utiles

```bash
# Ouvrir un terminal PostgreSQL dans le container (remplacer stage par dev ou prod)
docker compose -f docker/docker-compose.stage.yml exec db psql -U postgres -d cesizen_stage

# Compter les articles
docker compose -f docker/docker-compose.stage.yml exec db psql -U postgres -d cesizen_stage -c "SELECT COUNT(*) FROM article_sante;"

# Lister les tables
docker compose -f docker/docker-compose.stage.yml exec db psql -U postgres -d cesizen_stage -c "\dt"

# Ajouter une colonne manquante (exemple)
docker compose -f docker/docker-compose.stage.yml exec db psql -U postgres -d cesizen_stage -c "ALTER TABLE activity ADD COLUMN IF NOT EXISTS photo VARCHAR(255);"
```

---

## Tests

```bash
# Lancer tous les tests
python -m pytest tests/ -v

# Lancer uniquement les tests unitaires
python -m pytest tests/unit/ -v

# Lancer uniquement les tests fonctionnels
python -m pytest tests/functional/ -v
```

---

## Git — Convention de commits

```
<type>(<scope>): <description>
```

| Type | Quand l'utiliser |
|---|---|
| feat | Nouvelle fonctionnalité |
| fix | Correction de bug |
| docs | Documentation uniquement |
| style | Mise en forme, pas de changement fonctionnel |
| refactor | Réécriture sans changement de comportement |
| test | Ajout ou modification de tests |
| chore | Dépendances, config CI, tâches techniques |

Exemples :
```bash
git commit -m "feat(auth): ajouter la connexion par JWT"
git commit -m "fix(deps): corriger les failles de sécurité vite et postcss"
git commit -m "chore(deps): configurer Dependabot"
```

---

## Git — Flux de travail

```bash
# Créer une branche depuis dev
git checkout dev
git pull
git checkout -b 99-nom-de-la-feature

# Pousser la branche
git push -u origin 99-nom-de-la-feature
```

petit test pour tester
