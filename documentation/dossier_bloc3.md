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
5. [Conclusion](#5-conclusion)

---

## Introduction

Ce dossier présente le travail réalisé dans le cadre du Bloc 3 du titre **Concepteur Développeur d'Applications** à CESI, centré sur le déploiement, la maintenance et la sécurisation d'une application informatique.

Le projet choisi est **CESIZen**, une application web de bien-être mental que j'ai développée en Python/FastAPI pour le backend et Vue 3 pour le frontend. Ce dossier documente toutes les décisions prises pour rendre cette application déployable de façon fiable, maintenable dans le temps, et suffisamment sécurisée pour accueillir des utilisateurs réels.

J'ai cherché à utiliser des outils professionnels déjà intégrés à GitHub plutôt que des solutions externes, pour garder un écosystème cohérent et limiter la complexité. Toutes les configurations décrites ici correspondent à ce qui est réellement en place dans le dépôt du projet.

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
| Staging | `.env.stage` | `docker compose -f docker/docker-compose.stage.yml up -d` |
| Production | `.env.prod` | `docker compose -f docker/docker-compose.prod.yml up -d` |

#### Environnement de développement

Utilisé au quotidien sur les branches des différentes issues. A chaque nouvelle feature, une issue est créée avec sa branche associée. Le code source est monté en **volume** dans le container backend — toute modification de fichier Python est visible instantanément sans rebuild. Uvicorn tourne avec `--reload`. Le frontend utilise le serveur Vite avec hot reload.

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

#### Isolation des bases de données

Chaque environnement dispose de sa propre base de données, isolée des autres à deux niveaux.

**Au niveau des volumes Docker** — les données PostgreSQL sont stockées dans un volume dédié par environnement. Ces volumes sont complètement indépendants : lancer l'environnement de dev ne touche jamais aux données de staging ou de production.

| Environnement | Volume | Base de données |
|---|---|---|
| Dev | `pgdata_dev` | `cesizen_dev` |
| Staging | `pgdata_stage` | `cesizen_stage` |
| Production | `pgdata_prod` | `cesizen` |

**Au niveau du nom de la base** — chaque fichier `.env` définit un `POSTGRES_DB` différent. PostgreSQL crée la base correspondante au premier démarrage et y écrit toutes les données.

Quand un container `db` s'arrête, le volume persiste. Au redémarrage suivant, PostgreSQL retrouve ses données exactement là où il les avait laissées. Casser la base de développement n'affecte ni le staging ni la production.

---

### 2.3 Versioning

#### Stratégie de branches

Le projet applique une convention de nommage simple pour les branches. Chaque nouvelle fonctionnalité ou correction démarre depuis une branche dédiée, créée à partir de l'identifiant de l'issue GitHub associée :

```
{id-issue}-nom-court-de-la-feature
```

Exemples : `76-fix-template-github-issues`, `24-back-office-admin`.

Ce nommage permet de retrouver immédiatement l'issue GitHub correspondante à partir du nom de la branche, sans avoir à consulter les commits.

#### Convention de commits

Tous les commits respectent le format **Conventional Commits** :

```
<type>(<scope>): <description courte>
```

Les types utilisés dans le projet :

| Type | Quand l'utiliser |
|---|---|
| `feat` | Ajout d'une nouvelle fonctionnalité |
| `fix` | Correction d'un bug |
| `docs` | Modification de la documentation uniquement |
| `style` | Changement de mise en forme sans impact fonctionnel |
| `refactor` | Réécriture de code sans changement de comportement |
| `test` | Ajout ou modification de tests |
| `chore` | Tâches techniques (dépendances, config CI...) |

Exemples de commits réels dans le projet :
```
feat(auth): ajouter la connexion par JWT
fix(deps): corriger les failles de sécurité vite et postcss
chore(deps): configurer Dependabot pour la veille Python, npm et Actions
feat(ci): ajouter npm audit dans le pipeline de staging
```

Cette convention sert deux objectifs : elle rend l'historique Git lisible en un coup d'œil, et elle est utilisée par **semantic-release** pour calculer automatiquement le numéro de version suivant.

#### Versioning sémantique

Le projet suit le **versioning sémantique** (SemVer), dont le format est `vMAJEUR.MINEUR.PATCH` :

| Partie | Quand elle augmente |
|---|---|
| `PATCH` | Correction de bug (`fix:`) |
| `MINOR` | Nouvelle fonctionnalité (`feat:`) |
| `MAJOR` | Changement cassant la compatibilité (`BREAKING CHANGE`) |

Exemples :
- `v1.0.1` → un bug a été corrigé
- `v1.1.0` → une nouvelle fonctionnalité a été ajoutée
- `v2.0.0` → l'API a changé de façon incompatible avec la version précédente

#### semantic-release — versioning automatisé

Plutôt que de créer les tags de version manuellement, j'ai mis en place **semantic-release**, un outil qui analyse les commits à chaque merge sur `main` et calcule automatiquement le prochain numéro de version.

Son fonctionnement est le suivant :
1. Il lit tous les commits depuis le dernier tag
2. Il détermine le type de changement (patch / minor / major) selon les types de commits
3. Il crée un **tag Git** (`v1.2.0` par exemple) et une **GitHub Release** correspondante
4. Il déclenche ensuite la publication de l'image Docker avec ce numéro de version

La configuration est dans le fichier `.releaserc.json` à la racine du projet :

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/github"
  ]
}
```

Si aucun commit `feat:` ou `fix:` n'est présent dans le merge (par exemple un commit `chore:` uniquement), aucune release n'est créée et aucune image Docker n'est publiée — ce qui évite de créer des versions inutiles.

#### GitHub Releases

Chaque release créée par semantic-release génère automatiquement une **GitHub Release** visible dans l'onglet "Releases" du dépôt. Elle liste tous les changements depuis la version précédente, organisés par type (corrections, nouvelles fonctionnalités). Cela joue le rôle de changelog public du projet.

---

### 2.4 Pipeline CI/CD

Le pipeline est géré via **GitHub Actions** avec trois workflows distincts, un par cible de merge.

#### Déclenchement par environnement

```
Branche issue  ──PR──►  dev    →  ci.yml         (tests pytest)
dev            ──PR──►  stage  →  ci-stage.yml   (tests + audit + build Docker)
stage          ──PR──►  main   →  docker-publish.yml  (tests + release + publish image)
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

Déclenché à chaque Pull Request ciblant la branche `stage`. Vérifie les tests, audit les dépendances npm, et que les containers démarrent correctement.

| Étape | Action |
|---|---|
| 1 | Tests pytest (même logique que ci.yml) |
| 2 | Audit de sécurité des dépendances npm (`npm audit --audit-level=high`) |
| 3 | Build des images Docker backend et frontend |
| 4 | Démarrage des trois containers via `docker-compose.stage.yml` |
| 5 | Vérification que le backend répond sur `/docs` |
| 6 | Affichage de l'état des containers (même en cas d'échec) |

L'audit npm est configuré avec le niveau `high` : les vulnérabilités de niveau modéré sont signalées mais ne bloquent pas le pipeline. Seules les vulnérabilités de niveau élevé ou critique bloquent le merge, ce qui évite de bloquer le développement pour des problèmes non urgents.

#### `docker-publish.yml` — Push vers `main`

Déclenché à chaque merge sur `main`. Analyse les commits, crée une release si nécessaire, puis publie l'image Docker.

| Étape | Action |
|---|---|
| 1 | Tests pytest (filet de sécurité avant publication) |
| 2 | semantic-release : analyse des commits et création du tag + GitHub Release |
| 3 | Si une nouvelle version est publiée : build et push de l'image Docker |

L'image est publiée sur le **GitHub Container Registry** (`ghcr.io`) avec deux tags :
- `:latest` → toujours la version la plus récente
- `:v1.2.0` → le numéro de version exact (permet un rollback rapide vers n'importe quelle version précédente)

Le job de publication Docker ne se lance **que si semantic-release a créé une nouvelle release**. Si le merge ne contient que des commits `chore:` ou `docs:`, le job est automatiquement ignoré.

---

## 3. Plan de maintenance

### 3.1 Outil de gestion des tickets

Pour gérer les corrections et évolutions du projet, j'ai utilisé les **GitHub Issues** directement intégrées au dépôt. L'avantage principal est que tout est au même endroit : le code, les branches, les pull requests et les tickets sont liés sans avoir besoin d'un outil externe.

#### Templates d'issues

Deux templates ont été créés pour guider la création d'une issue et s'assurer que toutes les informations utiles sont renseignées dès le départ.

**Template Bug — Incident** (`.github/ISSUE_TEMPLATE/bug_report.yml`)

Ce formulaire demande à la personne qui signale un bug de préciser :
- La **sévérité** du problème (parmi trois niveaux décrits ci-dessous)
- L'**environnement** touché (production, staging ou développement)
- La **description** du problème
- Les **étapes pour reproduire** le bug
- Le **comportement attendu** versus le comportement observé
- Des **informations complémentaires** (logs, captures d'écran...)

**Template Évolution** (`.github/ISSUE_TEMPLATE/feature_request.yml`)

Ce formulaire demande :
- La **priorité** de la demande
- La **description** de la fonctionnalité souhaitée
- La **justification métier** (pourquoi cette fonctionnalité est utile)
- Les **critères d'acceptation** (comment savoir que c'est terminé)

#### Labels

Les labels permettent de catégoriser les issues et de les filtrer rapidement dans la liste. Voici les labels en place dans le projet :

**Labels de sévérité pour les bugs :**

| Label | Signification |
|---|---|
| `bug:bloquant` | Le service est inutilisable — correction urgente |
| `bug:majeur` | Le service est intermittent ou dégradé |
| `bug:mineur` | La qualité est réduite mais le service fonctionne |

**Labels de type :**

| Label | Signification |
|---|---|
| `evolution:prioritaire` | Nouvelle fonctionnalité à traiter en priorité |
| `evolution:standard` | Nouvelle fonctionnalité à traiter dans le cours normal du travail |
| `veille` | Mise à jour de dépendance proposée par Dependabot |

Le template de bug affiche directement les trois niveaux de sévérité avec leur description dans le formulaire, pour que la personne qui signale le problème puisse choisir le bon niveau sans hésiter.

#### GitHub Project — tableau kanban

Un **GitHub Project** est associé au dépôt pour visualiser l'état d'avancement de chaque issue. Il s'agit d'un tableau kanban avec cinq colonnes :

| Colonne | Signification |
|---|---|
| À faire | Issue créée, non encore démarrée |
| En cours | Une branche a été créée, le travail est commencé |
| En révision | Une Pull Request est ouverte, le code est relu |
| À valider | La PR est mergée, en attente de validation fonctionnelle |
| Terminé | Validé et déployé |

Chaque issue créée apparaît automatiquement dans la colonne "À faire". Elle avance dans le tableau au fil de son cycle de vie.

---

### 3.2 Méthodologie de gestion des corrections et évolutions

#### Cycle de vie d'un ticket

Que ce soit un bug ou une évolution, chaque modification du projet passe par le même processus :

**1. Création de l'issue**
Une issue est ouverte sur GitHub avec le bon template. Elle reçoit un identifiant unique (par exemple `#76`). Elle est ajoutée au GitHub Project dans la colonne "À faire".

**2. Création de la branche**
Une branche est créée à partir de `dev`, nommée avec l'identifiant de l'issue :
```
git checkout dev
git pull
git checkout -b 76-fix-template-github-issues
```

**3. Développement et commits**
Le code est modifié localement. Chaque commit respecte la convention :
```
fix(templates): corriger les options de sévérité dans le formulaire de bug
```

**4. Pull Request et relecture**
Une PR est ouverte de la branche vers `dev`. Le pipeline CI vérifie automatiquement que les tests passent. Si tout est bon, la PR peut être mergée. L'issue passe en colonne "En révision" pendant cette étape.

**5. Validation en staging**
Depuis `dev`, une PR est ouverte vers `stage`. Le pipeline CI plus complet (tests + audit npm + démarrage des containers) vérifie que l'ensemble fonctionne dans un environnement proche de la production.

**6. Mise en production**
Une PR est ouverte de `stage` vers `main`. Au merge, semantic-release analyse les commits et crée une release si nécessaire. L'image Docker est publiée. L'issue est fermée et passe en colonne "Terminé".

#### Gestion des priorités

Les bugs bloquants (`bug:bloquant`) sont traités en priorité absolue et passent devant toutes les évolutions en cours. Les bugs majeurs (`bug:majeur`) sont traités dans la foulée des travaux en cours. Les bugs mineurs et les évolutions standards suivent le backlog normal.

---

### 3.3 Veille technologique

La veille technologique recouvre deux choses distinctes : surveiller les nouvelles vulnérabilités dans les dépendances du projet, et se tenir informé des évolutions des outils utilisés. Pour CESIZen, j'ai mis en place deux mécanismes automatisés.

#### Dependabot — mises à jour automatiques des dépendances

**Dependabot** est un service intégré à GitHub qui surveille les dépendances du projet et ouvre automatiquement des Pull Requests quand une nouvelle version est disponible. Il est configuré dans le fichier `.github/dependabot.yml`.

Trois écosystèmes sont surveillés :

| Écosystème | Dossier surveillé | Ce qui est vérifié |
|---|---|---|
| `pip` | `/` | Dépendances Python (`requirements.txt`) |
| `npm` | `/frontend` | Dépendances JavaScript (`package.json`) |
| `github-actions` | `/` | Versions des actions dans les workflows CI/CD |

La fréquence de vérification est hebdomadaire pour les trois. Chaque PR créée par Dependabot reçoit automatiquement le label `veille`.

Quand Dependabot ouvre une PR, il faut évaluer si la mise à jour est urgente ou non :
- Si la PR mentionne une **CVE** (identifiant de vulnérabilité) ou si le changelog indique un **security fix**, c'est à traiter en priorité
- Si c'est une mise à jour de fonctionnalité sans mention de sécurité, elle peut attendre le prochain cycle de travail normal

Les PR Dependabot passent par le même pipeline CI que les autres : les tests doivent passer avant de pouvoir merger. Cela évite d'introduire une régression en voulant corriger une faille.

#### npm audit — audit des vulnérabilités connues

En complément de Dependabot, un **audit npm** est intégré directement dans le pipeline CI de staging (`ci-stage.yml`). À chaque PR vers `stage`, la commande `npm audit --audit-level=high` est exécutée et analyse les 140 dépendances du frontend par rapport à une base de données de vulnérabilités connues.

Concrètement, si une dépendance présente une CVE de niveau élevé ou critique, le pipeline échoue et le merge est bloqué jusqu'à correction. Les vulnérabilités de niveau modéré ou faible sont signalées dans les logs mais ne bloquent pas.

En pratique, cet audit a déjà permis de détecter et corriger deux vulnérabilités avant qu'elles n'atteignent la production :
- `postcss < 8.5.10` — vulnérabilité XSS de niveau modéré
- `vite 7.0.0 – 7.3.1` — lecture arbitraire de fichiers (Path Traversal) de niveau élevé

Ces deux failles ont été corrigées par `npm audit fix` qui a mis à jour les versions concernées automatiquement.

---

## 4. Plan de sécurisation

### 4.1 Analyse des vulnérabilités et risques

#### Périmètre de l'analyse

CESIZen est une application web accessible au public qui stocke des données personnelles (email, mot de passe, données de santé mentale). Le périmètre de l'analyse couvre :
- L'API backend (FastAPI)
- Le frontend (Vue 3)
- La base de données (PostgreSQL)
- L'infrastructure Docker et CI/CD

#### Risques identifiés

L'analyse s'appuie sur les catégories du référentiel **OWASP Top 10**, qui liste les dix risques de sécurité les plus courants dans les applications web.

| Risque OWASP | Description dans le contexte CESIZen | Niveau |
|---|---|---|
| **Contrôle d'accès défaillant** | Un utilisateur pourrait accéder aux données d'un autre utilisateur ou à l'espace d'administration sans les droits | Élevé |
| **Échecs cryptographiques** | Les mots de passe stockés en clair seraient récupérables en cas de fuite de la base de données | Élevé |
| **Injection** | Des requêtes SQL malveillantes pourraient être injectées via les champs du formulaire pour lire ou modifier la base | Élevé |
| **Composants vulnérables** | Des dépendances Python ou npm avec des CVE connues pourraient être exploitées | Moyen |
| **Mauvaise configuration de sécurité** | Des variables d'environnement exposées, des ports inutilement ouverts, ou des droits trop larges sur les containers | Moyen |
| **Falsification de requêtes (CSRF)** | Un site malveillant pourrait déclencher des actions au nom d'un utilisateur connecté | Moyen |
| **Exposition de données sensibles** | Les données de santé mentale des utilisateurs pourraient être accessibles sans chiffrement | Élevé |

#### Matrice de risques

La matrice ci-dessous classe chaque risque selon sa **probabilité** (chances que ça arrive) et son **impact** (dommages si ça arrive) :

|  | Impact faible | Impact moyen | Impact élevé |
|---|---|---|---|
| **Probabilité élevée** | — | Composants vulnérables | Injection SQL |
| **Probabilité moyenne** | — | Mauvaise configuration | Contrôle d'accès · Données sensibles |
| **Probabilité faible** | CSRF | — | Mots de passe en clair |

---

### 4.2 Actions correctives et préventives

#### Authentification et gestion des mots de passe

Les mots de passe ne sont jamais stockés en clair dans la base de données. Ils sont hashés avec **bcrypt** avant d'être enregistrés. bcrypt est un algorithme de hachage conçu spécifiquement pour les mots de passe : il est intentionnellement lent, ce qui rend les attaques par force brute très coûteuses en temps même si la base de données est volée.

L'authentification utilise des **tokens JWT** (JSON Web Token). Quand un utilisateur se connecte, le backend lui délivre un token signé avec une clé secrète (`SECRET_KEY`) stockée dans les variables d'environnement. Ce token a une durée de vie limitée. Le frontend l'envoie dans l'en-tête de chaque requête protégée. Le backend vérifie la signature avant de répondre — sans jamais interroger la base de données pour chaque requête.

#### Protection contre les injections SQL

L'accès à la base de données passe exclusivement par **SQLAlchemy**, un ORM Python. Les requêtes sont construites via des objets Python, jamais par concaténation de chaînes de caractères. SQLAlchemy paramètre automatiquement toutes les valeurs avant de les envoyer à PostgreSQL, ce qui rend les injections SQL impossibles par construction.

#### Gestion des secrets

Aucun secret (mot de passe, clé d'API, token) n'est écrit dans le code ou dans les fichiers commités. Toutes les variables sensibles passent par des fichiers `.env` qui sont listés dans `.gitignore`. Dans le pipeline CI/CD, les secrets sont injectés via les **GitHub Secrets** et ne sont jamais visibles dans les logs.

#### Isolation réseau

En production, seul le port 80 (Nginx) est exposé à l'extérieur. Le backend et la base de données sont dans le réseau Docker interne et ne sont accessibles que par les autres containers. Un utilisateur externe ne peut pas atteindre directement la base de données.

#### Audit automatique des dépendances

Deux mécanismes complémentaires surveillent les dépendances en permanence (détaillés en section 3.3) :
- **Dependabot** ouvre automatiquement des PR quand une nouvelle version corrigeant une faille est disponible
- **npm audit** bloque le merge vers staging si une vulnérabilité de niveau élevé est détectée

Ces deux outils ensemble permettent de ne jamais laisser une faille connue atteindre la production sans l'avoir traitée.

#### HTTPS

En environnement de production réel, le trafic doit transiter en HTTPS. Nginx est configuré comme point d'entrée unique de l'application et peut être complété par un certificat TLS (Let's Encrypt par exemple) pour chiffrer les communications entre le navigateur et le serveur. Cela protège notamment les tokens JWT et les données personnelles en transit.

---

### 4.3 Données personnelles et RGPD

#### Données collectées

CESIZen collecte un nombre limité de données personnelles :

| Donnée | Finalité | Durée de conservation |
|---|---|---|
| Adresse email | Identification du compte | Durée de vie du compte |
| Mot de passe hashé | Authentification | Durée de vie du compte |
| Articles en favoris | Personnalisation de l'expérience | Durée de vie du compte |

Aucune donnée de santé mentale nominative n'est collectée. Les articles et activités sont des contenus publics consultés de façon anonyme ou en tant qu'utilisateur connecté. L'application ne partage aucune donnée avec des services tiers.

#### Droits des utilisateurs

Conformément au RGPD, les utilisateurs disposent des droits suivants :
- **Droit d'accès** : consulter les données associées à leur compte
- **Droit de rectification** : modifier leur adresse email
- **Droit à l'effacement** : supprimer leur compte et les données associées
- **Droit d't opposition** : ne pas recevoir de communications non sollicitées (l'application n'en envoie pas)

Ces droits sont accessibles directement depuis l'interface de gestion du compte.

#### Sécurité du stockage

Les données sont stockées dans une base de données PostgreSQL dans un volume Docker non exposé publiquement. Les mots de passe sont hashés et ne peuvent pas être récupérés en clair, même par un administrateur. En cas de fuite de la base de données, les mots de passe ne seraient pas directement exploitables.

---

### 4.4 Gestion de crise

#### Détection d'un incident

La détection repose sur plusieurs sources :
- **Les logs de l'application** : le backend FastAPI journalise toutes les erreurs 500 et les tentatives d'accès non autorisées (erreurs 401/403)
- **L'état des containers** : `docker compose ps` permet de vérifier instantanément si un service est en cours d'exécution ou a crashé
- **GitHub Actions** : si un workflow échoue lors d'un déploiement, une notification est envoyée par email à l'administrateur du dépôt

#### Niveaux de gravité et procédure d'escalade

| Niveau | Symptôme | Action immédiate |
|---|---|---|
| **Critique** | Service complètement inaccessible | Rollback vers l'image Docker précédente, investigation |
| **Majeur** | Fonctionnalité clé indisponible ou données corrompues | Créer une issue `bug:bloquant`, corriger en urgence |
| **Mineur** | Comportement anormal sans impact fort sur le service | Créer une issue `bug:mineur`, planifier la correction |

#### Procédure de rollback

Grâce au double tag des images Docker (`:latest` et `:vX.Y.Z`), il est possible de revenir à une version précédente en quelques minutes. Chaque version publiée est archivée dans le GitHub Container Registry.

Pour revenir à la version `v1.1.0` par exemple, il suffit de modifier la référence d'image dans le fichier `docker-compose.prod.yml` et de relancer les containers.

#### Communication en cas d'incident

En cas d'incident affectant les utilisateurs, la procédure est la suivante :
1. Identifier la cause et estimer la durée de l'indisponibilité
2. Si l'indisponibilité dépasse 15 minutes, informer les utilisateurs concernés
3. Une fois résolu, documenter l'incident dans une issue GitHub : cause, actions menées, durée, et mesures prises pour éviter que ça se reproduise

---

### 4.5 Bonnes pratiques de développement

#### Protection des branches principales

Les branches `main`, `stage` et `dev` sont **protégées** sur GitHub : il est impossible de pusher directement dessus. Tout changement doit passer par une Pull Request. Le pipeline CI doit être vert avant que le merge soit autorisé. Cela garantit qu'aucun code non testé n'atteint jamais la production.

#### Revue de code

Chaque PR doit être relue avant d'être mergée. Cette étape permet de détecter des erreurs logiques, des problèmes de sécurité, ou du code difficile à maintenir, avant qu'ils ne soient intégrés. Dans un projet en solo, la relecture se fait en prenant du recul sur son propre code avant de valider.

#### Convention de commits et traçabilité

Les commits conventionnels permettent de reconstituer l'historique des changements sans ambiguïté. En cas de bug en production, il est possible de retrouver exactement quel commit a introduit le problème (via `git bisect` ou simplement en lisant l'historique) et d'identifier la feature associée via l'identifiant d'issue dans le nom de branche.

#### Tests automatisés

Tous les endpoints de l'API sont couverts par des tests pytest. Ces tests sont lancés automatiquement à chaque PR, ce qui permet de détecter les régressions avant qu'elles n'atteignent les utilisateurs.

#### Séparation des environnements

Le code ne contient aucune référence en dur à un environnement particulier. La configuration (URL de la base, clé secrète, etc.) vient exclusivement des variables d'environnement. Il est donc impossible d'exécuter du code de production en mode développement par accident.

---

## 5. Conclusion

Ce projet m'a permis de mettre en place l'ensemble des éléments nécessaires pour passer d'une application fonctionnelle en local à une application déployable, maintenable et sécurisée.

Sur la partie **déploiement**, Docker et Docker Compose permettent de reproduire le même environnement à tous les niveaux, de la machine du développeur jusqu'à la production. Le pipeline CI/CD automatise les vérifications à chaque étape et réduit le risque d'erreur humaine. Le versioning sémantique automatisé via semantic-release donne une visibilité claire sur l'état de l'application et simplifie les rollbacks.

Sur la partie **maintenance**, GitHub Issues avec ses templates et labels structure la gestion des tickets dès la création de l'issue. Le tableau kanban donne une vue d'ensemble de ce qui est en cours et de ce qui est terminé. Dependabot et npm audit fonctionnent en parallèle pour surveiller les dépendances en permanence, sans avoir besoin d'y penser manuellement.

Sur la partie **sécurité**, les principaux risques identifiés (injection SQL, mots de passe, contrôle d'accès) ont été traités au niveau du code grâce à SQLAlchemy, bcrypt et JWT. Les vulnérabilités dans les dépendances sont détectées et bloquées automatiquement avant d'atteindre la production.

L'ensemble de ces outils repose sur des fonctionnalités natives de GitHub, ce qui évite de multiplier les plateformes et simplifie la prise en main pour d'éventuels collaborateurs.