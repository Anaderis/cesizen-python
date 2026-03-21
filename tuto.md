# API Python avec Fast API + PostGreSQL

# Création de l'envionnement virtuel
python -m venv pythonCesizen

# Activer l'environnement avec cmd
env\Scripts\activate

# Activer l'environnement avec Powershell
.\pythonCesizen\Scripts\Activate.ps1

# Installer les dépendances
pip install fastapi uvicorn psycopg2-binary sqlalchemy

# Sauvegarder les dépendances
pip freeze > requirements.txt

# Désactiver l'environnement
deactivate

# Réinstaller les dépendances
pip install -r requirements.txt

# Lancer l'API
uvicorn app.main:app --reload

# Installation de uvicorn avec python puisque windows fait ce qu'il veut
python -m uvicorn app.main:app --reload