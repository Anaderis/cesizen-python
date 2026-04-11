# Documentation Technique — CESIZen

**Projet :** CESIZen — L'application de votre santé mentale  
**Titre :** Concepteur Développeur d'Applications (CDA)  
**Activité :** 2 — Développer et tester les applications informatiques  
**Auteur :** Anaïs  
**Date :** Avril 2026

---

## Sommaire

1. [MCD — Modèle Conceptuel de Données](#1-mcd--modèle-conceptuel-de-données)
2. [MLD — Modèle Logique de Données](#2-mld--modèle-logique-de-données)
3. [Comparatif des solutions techniques](#3-comparatif-des-solutions-techniques)
4. [Choix final de la solution](#4-choix-final-de-la-solution)
5. [Guide d'installation](#5-guide-dinstallation)
6. [Cahier de recette et scénarii de tests](#6-cahier-de-recette-et-scénarii-de-tests)
7. [Procédure de validation et modèle de PV de recette](#7-procédure-de-validation-et-modèle-de-pv-de-recette)

---

## 1. MCD — Modèle Conceptuel de Données

Le Modèle Conceptuel de Données (MCD) représente les informations manipulées par l'application et les liens qui existent entre elles. C'est une vue qui permet de comprendre la structure des données avant de les implémenter en base de données.

### Les entités

Le MCD de CESIZen est composé des entités suivantes :

| Entité | Description |
|--------|-------------|
| **Utilisateur** | Toute personne ayant un compte sur l'application (utilisateur ou administrateur) |
| **Role** | Définit le niveau d'accès d'un utilisateur (utilisateur standard ou administrateur) |
| **Articles_Santé** | Articles informatifs sur la santé mentale, consultables par tous |
| **Catégorie** | Permet de classer les articles et les activités par thème |
| **Activités_détente** | Activités proposées aux utilisateurs pour gérer leur stress |
| **Format** | Définit le type de support d'une activité (vidéo, PDF, lien externe, etc.) |
| **Log** | Enregistre les actions réalisées par les administrateurs sur l'application |

### Les relations

| Relation | Description |
|----------|-------------|
| **est** | Un utilisateur possède un rôle (utilisateur ou administrateur) |
| **TJ_Accède** | Un utilisateur peut générer des entrées dans les logs (actions d'administration) |
| **TJ_Favori** | Un utilisateur peut marquer plusieurs activités comme favorites |
| **appartient_à** | Un article appartient à une catégorie |
| **appartient** | Une activité appartient à une catégorie |
| **possède** | Une activité possède un format (vidéo, PDF, etc.) |

### Diagramme

![MCD CESIZen](diagrams/mcd-cesizen.jpg)

---

## 2. MLD — Modèle Logique de Données

Le Modèle Logique de Données (MLD) est la traduction du MCD en tables concrètes, telles qu'elles sont réellement créées dans la base de données PostgreSQL. Chaque entité devient une table, et chaque relation devient une clé étrangère ou une table de liaison.

### Les tables

| Table | Clé primaire | Clés étrangères | Description |
|-------|-------------|-----------------|-------------|
| **utilisateur** | `id` | `role_id` → role | Stocke les comptes utilisateurs |
| **role** | `id` | — | Contient les rôles disponibles (utilisateur, administrateur) |
| **article_sante** | `id` | `category_id` → category | Stocke les articles publiés |
| **category** | `id` | — | Liste des catégories (articles et activités) |
| **activity** | `id` | `category_id` → category, `format_id` → format | Stocke les activités proposées |
| **format** | `id` | — | Types de supports disponibles pour les activités |
| **favorites** | `user_id` + `activity_id` | `user_id` → user, `activity_id` → activity | Table de liaison pour les favoris |
| **log** | `id` | `user_id` → user | Historique des actions des administrateurs |

### Points clés

- La table **favorites** est une table de liaison qui matérialise la relation plusieurs-à-plusieurs entre un utilisateur et ses activités favorites : un utilisateur peut avoir plusieurs favoris, et une activité peut être mise en favori par plusieurs utilisateurs. Elle n'a pas de clé primaire unique — c'est la combinaison de `user_id` et `activity_id` qui identifie chaque ligne.
- La table **log** est rattachée à un utilisateur via `user_id`, ce qui permet de savoir quel administrateur a effectué chaque action.
- Les tables **category** et **format** sont des tables de référence : elles contiennent des valeurs fixes qui sont réutilisées par d'autres tables.

### Diagramme

![MLD CESIZen](diagrams/mld-cesizen.jpg)

---

## 3. Comparatif des solutions techniques

### 3.1 Contexte et objectifs

Avant de démarrer le développement de CESIZen, il a fallu choisir les technologies à utiliser. Ce choix est important car il conditionne la manière dont l'application sera construite, testée et maintenue dans le temps.

Les principales contraintes à prendre en compte étaient les suivantes :

- L'application doit être accessible à tout le monde (visiteurs non connectés, utilisateurs et administrateurs)
- Les données des utilisateurs doivent être protégées par une connexion sécurisée
- Un espace d'administration doit permettre de gérer les contenus et les comptes
- L'application doit communiquer via une API, c'est-à-dire un point d'échange entre le serveur et l'interface utilisateur
- Des tests automatisés doivent garantir que l'application fonctionne correctement à chaque modification

Trois solutions techniques ont été étudiées et comparées avant de retenir la solution finale.

---

### 3.2 Architectures étudiées

#### Architecture A — Django (Python) + Django Templates

**Description :**  
Django est un framework Python très complet qui fournit tous les outils essentiels : gestion de la base de données, connexion des utilisateurs, interface d'administration, et génération des pages HTML directement côté serveur. Il n'est pas nécessaire d'ajouter de bibliothèques tierces pour démarrer un projet.

- **Côté serveur (backend) :** Django (Python)
- **Côté interface (frontend) :** Django Templates
- **Base de données :** PostgreSQL
- **Connexion des utilisateurs :** Système de sessions intégré à Django

**Points forts :**
- Très rapide à mettre en place grâce aux nombreux outils intégrés
- Interface d'administration générée automatiquement, sans code supplémentaire. Django inclut nativement un back-office d'administration accessible à l'URL /admin. Dès qu'on déclare un modèle de données (par exemple User ou Article), Django génère automatiquement le CRUD associé
- Framework stable, mature, avec une documentation très complète
- Sécurité robuste par défaut (protection contre les attaques courantes)

**Points faibles :**
- Les pages sont entièrement générées par le serveur : chaque changement à l'écran provoque un rechargement complet de la page, ce qui donne une expérience moins fluide
- La séparation entre l'interface et le serveur est peu marquée, ce qui rend l'évolution de l'un sans toucher à l'autre plus difficile
- Moins adapté si l'on souhaite proposer une application mobile ou un frontend indépendant dans le futur

---

#### Architecture B — FastAPI (Python) + Vue.js 3

**Description :**  
FastAPI est un framework Python conçu pour créer des APIs. Vue.js 3 est un framework JavaScript qui permet de construire l'interface de l'application directement dans le navigateur de l'utilisateur, sans rechargement de page.

- **Côté serveur (backend) :** FastAPI (Python) + SQLAlchemy pour la gestion de la base de données
- **Côté interface (frontend) :** Vue.js 3 
- **Base de données :** PostgreSQL
- **Connexion des utilisateurs :** JWT, un jeton de connexion sécurisé transmis à chaque requête

**Points forts :**
- Très performant : FastAPI est l'un des frameworks Python les plus rapides
- La validation des données est automatique, ce qui limite les erreurs et les données incorrectes. Si quelqu'un envoie une requête sans le champ email par exemple, ou avec un nombre à la place d'un texte, FastAPI rejette automatiquement la requête avec une erreur claire, sans qu'on ait besoin d'écrire de vérification manuelle dans le code.
- Une documentation de l'API est générée automatiquement et consultable en ligne depuis /docs
- L'interface Vue.js est fluide : la navigation ne recharge pas la page entière
- La séparation entre l'interface et le serveur est claire, ce qui facilite les tests et la maintenance
- L'ensemble du projet côté serveur est en Python, un seul langage à maîtriser

**Points faibles :**
- Nécessite de gérer deux projets distincts (backend et frontend), ce qui complexifie légèrement la mise en place initiale
- FastAPI est plus récent que Django : certaines fonctionnalités avancées nécessitent plus de configuration manuelle

---

#### Architecture C — Node.js (Express) + React

**Description :**  
Express.js est un framework pour Node.js, qui permet de créer des APIs en JavaScript côté serveur. React est une bibliothèque développée par Meta (Facebook) pour construire des interfaces web en JavaScript côté navigateur.

- **Côté serveur (backend) :** Node.js + Express.js
- **Côté interface (frontend) :** React
- **Base de données :** PostgreSQL
- **Connexion des utilisateurs :** JWT

**Points forts :**
- JavaScript utilisé à la fois côté serveur et côté interface : un seul langage pour tout le projet
- React est la bibliothèque frontend la plus utilisée dans l'industrie : nombreuses ressources disponibles
- Interface fluide et réactive, sans rechargement de page
- Grande flexibilité dans l'organisation du code

**Points faibles :**
- Express est minimaliste : il faut configurer manuellement beaucoup d'éléments (validation, sécurité, gestion des erreurs)
- La sécurité par défaut est moins complète que celle de Django ou FastAPI
- React a une courbe d'apprentissage plus difficile que Vue.js pour un projet de cette taille
- La gestion de la base de données via Sequelize est moins intuitive que SQLAlchemy

---

#### Architecture D — Quarkus (Java) + Qute

**Description :**  
Quarkus est un framework Java moderne, lancé en 2019 et soutenu par Red Hat. Il a été conçu dès le départ pour être léger, rapide à démarrer et économe en mémoire. Qute est son moteur de templates intégré, qui génère les pages HTML côté serveur — sans avoir besoin de JavaScript côté interface.

- **Côté serveur (backend) :** Quarkus (Java)
- **Côté interface (frontend) :** Qute — pages HTML générées par le serveur
- **Base de données :** PostgreSQL (via Hibernate ORM)
- **Connexion des utilisateurs :** JWT ou sessions, via l'extension Quarkus Security

**Points forts :**
- Très performant et léger : Quarkus démarre en quelques millisecondes et consomme peu de mémoire, ce qui le rend idéal pour un déploiement dans le cloud
- Java est un langage largement utilisé dans les entreprises et les institutions publiques : les équipes techniques sont souvent familières avec cet écosystème
- Soutenu par Red Hat, une entreprise reconnue : la pérennité du framework est assurée sur le long terme
- Bonne intégration des tests avec JUnit et les extensions Quarkus dédiées aux tests

**Points faibles :**
- La courbe d'apprentissage est plus difficile, notamment pour quelqu'un qui ne connaît pas l'écosystème Java. Le langage Java est également "plus" verbeux que Python.
- Qute génère les pages côté serveur comme Django Templates : l'interface manque de fluidité comparée à une application Vue.js ou React
- La communauté de Quarkus, bien qu'active, est plus petite que celle de Spring Boot ou de FastAPI

---

### 3.3 Critères d'évaluation

Chaque architecture est notée de **1 à 5** pour chacun des critères ci-dessous. Un poids est attribué à chaque critère selon son importance dans le contexte du projet CESIZen.

| # | Critère | Description | Poids |
|---|---------|-------------|-------|
| 1 | **Support et communauté** | Ancienneté de la technologie, taille de la communauté, qualité de la documentation | 15% |
| 2 | **Rapidité de développement** | Facilité de prise en main, outils intégrés, gain de temps au démarrage | 20% |
| 3 | **Performance** | Vitesse de réponse du serveur, capacité à gérer plusieurs utilisateurs simultanément | 15% |
| 4 | **Sécurité** | Protections intégrées contre les attaques, gestion des rôles, chiffrement des mots de passe | 15% |
| 5 | **Séparation interface / serveur** | Clarté de la séparation entre frontend et backend, facilité à faire évoluer chaque partie indépendamment | 10% |
| 6 | **Testabilité** | Facilité à écrire et automatiser des tests, compatibilité avec les outils de CI/CD | 15% |
| 7 | **Qualité de l'interface utilisateur** | Fluidité de navigation, réactivité, modernité de l'expérience côté utilisateur | 10% |

---

### 3.4 Tableau comparatif

| Critère | Poids | Archi. A — Django + Templates | Archi. B — FastAPI + Vue.js 3 | Archi. C — Express + React | Archi. D — Quarkus + Qute |
|---------|-------|:-----------------------------:|:------------------------------:|:---------------------------:|:-------------------------:|
| Support et communauté | 15% | **5** | **4** | **4** | **3** |
| Rapidité de développement | 20% | **5** | **4** | **3** | **2** |
| Performance | 15% | **3** | **5** | **4** | **5** |
| Sécurité | 15% | **5** | **4** | **3** | **4** |
| Séparation interface / serveur | 10% | **2** | **5** | **5** | **2** |
| Testabilité | 15% | **4** | **5** | **4** | **4** |
| Qualité de l'interface utilisateur | 10% | **2** | **5** | **5** | **2** |
| **Score** | **100%** | **3,75** | **4,55** | **3,85** | **3,35** |

**Classement final :**

| Position | Architecture | Score |
|:--------:|-------------|:-----:|
| 1er | FastAPI + Vue.js 3 | **4,55 / 5** |
| 2ème | Express + React | **3,85 / 5** |
| 3ème | Django + Templates | **3,75 / 5** |
| 4ème | Quarkus + Qute | **3,35 / 5** |

---

### 3.5 Analyse des résultats

**Architecture A — Django + Templates (3,75 / 5)**  
C'est la solution la plus simple et la plus rapide à mettre en place. Elle convient parfaitement à des projets où l'on veut aller vite et où l'interface n'a pas besoin d'être très dynamique. Cependant, le rendu serveur des pages HTML limite la fluidité de l'interface et rend difficile l'évolution indépendante du frontend et du backend. Pour CESIZen, qui nécessite une interface moderne et une API bien séparée, cette solution n'est pas la plus adaptée.

**Architecture B — FastAPI + Vue.js 3 (4,55 / 5)**  
C'est la solution la mieux notée. Elle combine les performances d'un framework Python moderne côté serveur avec la fluidité d'une interface construite dans le navigateur. La séparation claire entre l'API et l'interface facilite les tests, la maintenance et les évolutions futures. C'est l'architecture la plus cohérente avec les besoins du projet CESIZen.

**Architecture C — Express + React (3,85 / 5)**  
Cette solution est très répandue dans l'industrie et offre une interface fluide et moderne. Cependant, Express nécessite beaucoup de configuration manuelle pour des fonctionnalités que FastAPI ou Django intègrent nativement (sécurité, validation). React est également plus complexe à prendre en main que Vue.js pour un projet de cette échelle.

**Architecture D — Quarkus + Qute (3,35 / 5)**  
Quarkus est une solution très performante, particulièrement adaptée aux environnements cloud. Son appartenance à l'écosystème Java est particulièrement adaptée et prisée par les grandes organisations. Cependant, Java est plus verbeux que Python et la courbe d'apprentissage est plus longue. Le rendu des pages côté serveur avec Qute, comme pour Django Templates, ne permet pas d'obtenir une interface aussi fluide qu'avec Vue.js ou React. 

---

## 4. Choix final de la solution

### 4.1 Solution retenue

L'architecture retenue pour le projet CESIZen est l'**Architecture B : FastAPI (Python) + Vue.js 3**, avec PostgreSQL comme base de données et une authentification par JWT.

Cette solution obtient le meilleur score (**4,55 / 5**) et répond à l'ensemble des contraintes identifiées dans le cahier des charges.

---

### 4.2 Justification du choix

#### Côté serveur — FastAPI (Python)

FastAPI est un framework Python créé en 2018 qui permet de construire des APIs web de manière rapide et fiable. Il s'appuie sur des mécanismes du langage Python pour valider automatiquement les données reçues et garantir qu'elles correspondent bien à ce qui est attendu avant de les traiter ou de les enregistrer en base de données.

**Pourquoi FastAPI pour CESIZen :**

- **Rapidité :** FastAPI est l'un des frameworks Python les plus performants. Il peut traiter de nombreuses requêtes simultanément grâce à un mécanisme d'exécution asynchrone (les tâches n'attendent pas les unes les autres pour s'exécuter).
- **Validation automatique :** Grâce à la bibliothèque Pydantic, toutes les données envoyées à l'API sont vérifiées automatiquement. Cela réduit les risques d'erreurs ou d'injections de données malveillantes.
- **Documentation intégrée :** FastAPI génère automatiquement une page de documentation interactive (accessible sur `/docs`) qui liste toutes les routes disponibles et permet de les tester directement depuis le navigateur.
- **Gestion des droits d'accès :** Il est possible de définir facilement quelles routes sont accessibles aux visiteurs, aux utilisateurs connectés, ou uniquement aux administrateurs.
- **Gestion de la base de données :** L'intégration avec SQLAlchemy permet de manipuler la base de données en Python, sans écrire de requêtes SQL à la main.
- **Tests :** L'écosystème Python offre des outils de test très complets (`pytest`, `httpx`) qui s'intègrent bien avec FastAPI.

#### Côté interface — Vue.js 3

Vue.js 3 est un framework JavaScript qui permet de construire l'interface de l'application directement dans le navigateur. L'utilisateur navigue dans l'application sans que la page entière se recharge à chaque action.

**Pourquoi Vue.js 3 pour CESIZen :**

- **Prise en main accessible :** Vue.js est reconnu pour être plus simple à apprendre que React ou Angular, tout en restant très puissant pour des projets de taille moyenne.
- **Navigation fluide :** Grâce à Vue Router, le passage d'une page à l'autre est instantané côté navigateur, sans rechargement complet.
- **Gestion des données réactive :** Vue.js met automatiquement à jour l'interface dès qu'une donnée change (par exemple, l'affichage d'une liste de favoris après un clic).
- **Backend indépendant :** Le frontend communique avec l'API FastAPI uniquement via des requêtes HTTP. Les deux parties peuvent évoluer indépendamment.

#### Base de données — PostgreSQL

PostgreSQL est un système de gestion de base de données relationnelle fiable et performant, utilisé dans de nombreuses applications en production. Il garantit l'intégrité des données et s'intègre parfaitement avec SQLAlchemy. PGAdmin permet d'administrer facilement la base de données grâce à une interface graphique.

#### Authentification — JWT (JSON Web Tokens)

Lorsqu'un utilisateur se connecte, le serveur lui génère un jeton (token) qui contient ses informations de manière chiffrée. Ce jeton est ensuite envoyé avec chaque requête pour prouver que l'utilisateur est bien connecté. Cette approche est bien adaptée à une application où le frontend et le backend sont séparés.

---

### 4.3 Stack technique complète

| Composant | Technologie | Version | Rôle |
|-----------|-------------|---------|------|
| Backend | FastAPI | 0.115.x | Création de l'API REST |
| Gestion BDD | SQLAlchemy | 2.x | Communication avec la base de données |
| Validation | Pydantic | 2.x | Vérification et formatage des données |
| Serveur | Uvicorn | 0.34.x | Exécution de l'application FastAPI |
| Base de données | PostgreSQL | 16.x | Stockage des données |
| Frontend | Vue.js 3 | 3.x | Interface utilisateur dans le navigateur |
| Navigation | Vue Router | 4.x | Gestion des pages côté navigateur |
| Authentification | JWT  | — | Jetons de connexion sécurisés |
| Mots de passe | bcrypt | — | Chiffrement des mots de passe |
| Tests | pytest + httpx | — | Tests unitaires et fonctionnels |
| Automatisation | GitHub Actions | — | Exécution automatique des tests |

---

### 4.4 Respect du pattern MVC

L'architecture retenue respecte le Design Pattern **MVC (Modèle — Vue — Contrôleur)**, qui consiste à séparer clairement les trois grandes responsabilités d'une application :

| Couche | Rôle | Implémentation dans CESIZen |
|--------|------|-----------------------------|
| **Modèle** | Représente les données et leur structure | Modèles SQLAlchemy (`app/models/`) et schémas Pydantic (`app/schemas/`) |
| **Vue** | Ce que voit et utilise l'utilisateur | Composants Vue.js (`frontend/src/views/`) |
| **Contrôleur** | Traite les demandes et fait le lien entre les données et l'interface | Routes FastAPI (`app/controllers/`) et services métier (`app/services/`) |

Cette séparation permet de modifier une partie de l'application sans risquer d'en casser une autre, et facilite grandement l'écriture des tests.

---

## 5. Guide d'installation

Ce guide explique comment installer et lancer l'application CESIZen sur votre ordinateur, étape par étape.

### 5.1 Prérequis

Avant de commencer, vérifiez que les logiciels suivants sont installés sur votre machine :

| Logiciel | Version minimale | Utilité |
|----------|-----------------|---------|
| **Python** | 3.10 ou supérieur | Faire tourner le serveur FastAPI |
| **Node.js** | 20 ou supérieur | Faire tourner l'interface Vue.js |
| **PostgreSQL** | 14 ou supérieur | Base de données de l'application |
| **Git** | Toute version récente | Récupérer le code source |

Pour vérifier qu'un logiciel est bien installé, ouvrez un terminal et tapez :

```bash
python --version
node --version
psql --version
git --version
```

Si l'une de ces commandes affiche une erreur, installez le logiciel manquant avant de continuer.

---

### 5.2 Récupérer le code source

Ouvrez un terminal et placez-vous dans le dossier où vous souhaitez installer le projet, puis exécutez :

```bash
git clone https://github.com/Anaderis/cesizen-python.git
cd cesizen-python
```

---

### 5.3 Créer la base de données

Ouvrez PostgreSQL (via pgAdmin ou en ligne de commande) et créez une base de données nommée `cesizen` :

```sql
CREATE DATABASE cesizen;
```

Ensuite, importez les données initiales grâce au fichier SQL fourni dans le projet :

```bash
psql -U postgres -d cesizen -f app/static/sql/cesizen-0104.sql
```

> Remplacez `postgres` par votre nom d'utilisateur PostgreSQL si celui-ci est différent.

---

### 5.4 Configurer la connexion à la base de données

Les informations sensibles (mot de passe, clé secrète) sont stockées dans un fichier `.env` qui n'est pas partagé sur GitHub pour des raisons de sécurité. Il faut le créer manuellement.

Un fichier modèle [.env.example](../.env.example) est fourni dans le projet. Copiez-le et renommez la copie `.env` :


Ouvrez ensuite le fichier `.env` et renseignez vos propres informations :

```
SECRET_KEY=remplacez_par_une_cle_secrete
DATABASE_URL=postgresql://nom_utilisateur:mot_de_passe@localhost:5432/cesizen
```

Remplacez `votre_utilisateur` et `votre_mot_de_passe` par vos identifiants PostgreSQL.

> Pour générer une clé secrète sécurisée, vous pouvez utiliser la commande suivante dans un terminal Python :
> ```python
> import secrets; print(secrets.token_hex(32))
> ```

---

### 5.5 Installer et lancer le backend (FastAPI)

**Étape 1 — Créer un environnement virtuel Python**

Un environnement virtuel permet d'isoler les bibliothèques du projet sans affecter le reste de votre système.

```bash
python -m venv pythonCesizen
```

**Étape 2 — Activer l'environnement virtuel**

Sur Windows :
```bash
pythonCesizen\Scripts\activate
```

Activer l'environnement avec Powershell
```bash
.\pythonCesizen\Scripts\Activate.ps1
```

Sur Mac / Linux :
```bash
source pythonCesizen/bin/activate
```

Une fois activé, votre terminal affiche le nom de l'environnement au début de chaque ligne.

**Étape 3 — Installer les dépendances**

```bash
pip install -r requirements.txt
```
Sauvegarder les dépendances
```bash
pip freeze > requirements.txt
```

**Étape 4 — Lancer le serveur**

```bash
uvicorn app.main:app --reload
```

Le serveur est maintenant accessible à l'adresse : **http://localhost:8000**

La documentation interactive de l'API est disponible sur : **http://localhost:8000/docs**

---

### 5.6 Installer et lancer le frontend (Vue.js)

Ouvrez un **nouveau terminal** (gardez le premier ouvert pour le backend), puis placez-vous dans le dossier `frontend` :

```bash
cd frontend
```

**Étape 1 — Installer les dépendances**

```bash
npm install
```

**Étape 2 — Lancer l'interface**

```bash
npm run dev
```

L'interface est maintenant accessible à l'adresse : **http://localhost:5173**

---

### 5.7 Lancer les tests

Pour vérifier que tout fonctionne correctement, revenez dans le dossier racine du projet et exécutez :

```bash
pytest
```

Tous les tests doivent passer (affichage en vert). Si un test échoue, vérifiez que la base de données est bien configurée et que le serveur backend tourne correctement.

---

### 5.8 Résumé — ordre de démarrage

Pour utiliser CESIZen au quotidien, voici l'ordre à suivre à chaque démarrage :

1. Activer l'environnement virtuel Python (`pythonCesizen\Scripts\activate`)
2. Lancer le backend dans un terminal : `uvicorn app.main:app --reload`
3. Lancer le frontend dans un autre terminal : `cd frontend && npm run dev`
4. Ouvrir le navigateur sur **http://localhost:5173**

---

## 6. Cahier de recette et scénarii de tests

> *À rédiger*

---

## 7. Procédure de validation et modèle de PV de recette

> *À rédiger*
