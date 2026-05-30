# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Format : `<type>(<portée>) : <description>` — voir [CONTRIBUTING.md](CONTRIBUTING.md) pour les conventions complètes.

---

## [v1.0.0] — 2026-05-30

### Ajouts
- feat(docker) : mise en place des environnements Docker dev, staging et production
- feat(docker) : Dockerfile backend (Python 3.11 / Uvicorn / Gunicorn)
- feat(docker) : Dockerfile frontend multi-stage (Node build → Nginx)
- feat(docker) : configuration Nginx reverse proxy
- feat(ci) : workflow CI pour les Pull Requests vers `dev` (tests pytest)
- feat(ci) : workflow CI-stage pour les Pull Requests vers `stage` (tests + build Docker)
- feat(ci) : workflow docker-publish pour les merges vers `main` (publication ghcr.io)
- feat(github) : templates d'issues bug et évolution
- feat(github) : configuration Dependabot pour la veille des dépendances Python et npm

### Corrections
- fix(docker) : correction des variables d'environnement dans les fichiers Compose
- fix(docker) : correction du .dockerignore (exclusion du dossier frontend retirée)
- fix(backend) : ajout de gunicorn dans requirements.txt

### Documentation
- docs : rédaction du dossier bloc 3 (plan de déploiement, CI/CD, environnements Docker)

---

## Format des entrées

Chaque version suit la structure suivante :

```
## [vX.Y.Z] — YYYY-MM-DD

### Ajouts
- feat(...) : description

### Corrections
- fix(...) : description

### Maintenance
- chore(...) : description
```

**Numérotation sémantique :**
- `X` (majeur) : changement incompatible avec la version précédente
- `Y` (mineur) : nouvelle fonctionnalité rétrocompatible
- `Z` (patch) : correction de bug rétrocompatible