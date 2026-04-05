"""
Tests unitaires des schémas Pydantic.
Vérifie que les validateurs acceptent ou rejettent les bonnes valeurs,
sans toucher à la base de données.
"""
import pytest
from pydantic import ValidationError
from app.schemas.user_schema import UserCreate
from app.schemas.content_schema import ActivityCreate, ActivityUpdate

#====================================================================================
#       Ici on vérifie que les Schémas Pydantic fonctionnent correctement           #
# ===================================================================================      

# Ici pas besoin de la BDD de test, on teste juste les schémas et leurs validateurs.
# Les tests vérifient que les règles de validation (email, mot de passe, etc
# fonctionnent correctement

class TestUserCreateSchema:

# Pour chaque test, on vérifie si l'erreur est bien levée,
# Si aucune erreur n'est levée alors que c'était attendu, le test échoue (on utilise pytest.raises pour relever l'erreur).
# Du coup toutes les fonctions ne sont pas là pour relever des erreurs, 
# certaines vérifient juste que les données valides sont acceptées et transformées correctement 
    
    def test_valid_user(self):
        """Un utilisateur valide doit être accepté sans erreur."""
        user = UserCreate(
            name="Alice",
            surname="Dupont",
            email="alice@example.com",
            password="Secure1!"
        )
        assert user.email == "alice@example.com"

    def test_email_is_lowercased(self):
        """L'email doit être converti en minuscules automatiquement."""
        user = UserCreate(
            name="Alice", surname="Dupont",
            email="ALICE@EXAMPLE.COM", password="Secure1!"
        )
        assert user.email == "alice@example.com"

    def test_invalid_email(self):
        """Un email mal formaté doit lever une ValidationError."""
        with pytest.raises(ValidationError):
            UserCreate(
                name="Alice", surname="Dupont",
                email="pas-un-email", password="Secure1!"
            )

    def test_password_too_short(self):
        """Un mot de passe trop court doit être refusé."""
        with pytest.raises(ValidationError):
            UserCreate(
                name="Alice", surname="Dupont",
                email="alice@example.com", password="A1!"
            )

    def test_password_no_uppercase(self):
        """Un mot de passe sans majuscule doit être refusé."""
        with pytest.raises(ValidationError):
            UserCreate(
                name="Alice", surname="Dupont",
                email="alice@example.com", password="secure1!"
            )

    def test_password_no_digit(self):
        """Un mot de passe sans chiffre doit être refusé."""
        with pytest.raises(ValidationError):
            UserCreate(
                name="Alice", surname="Dupont",
                email="alice@example.com", password="Secure!!"
            )

    def test_password_no_special_char(self):
        """Un mot de passe sans caractère spécial doit être refusé."""
        with pytest.raises(ValidationError):
            UserCreate(
                name="Alice", surname="Dupont",
                email="alice@example.com", password="Secure12"
            )

    def test_empty_name(self):
        """Un nom vide (ou que des espaces) doit être refusé."""
        with pytest.raises(ValidationError):
            UserCreate(
                name="   ", surname="Dupont",
                email="alice@example.com", password="Secure1!"
            )

    def test_name_is_stripped(self):
        """Les espaces autour du nom doivent être supprimés."""
        user = UserCreate(
            name="  Alice  ", surname="Dupont",
            email="alice@example.com", password="Secure1!"
        )
        assert user.name == "Alice"


class TestActivityUrlValidator:
    """Teste le validateur d'URL appliqué à ActivityCreate et ActivityUpdate."""

    VALID_BASE = {"title": "Test", "category_id": 1, "format_id": 1}

    def test_youtube_url_accepted(self):
        """Une URL YouTube classique doit être acceptée."""
        a = ActivityCreate(**self.VALID_BASE, url="https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        assert a.url == "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

    def test_youtu_be_url_accepted(self):
        """Un lien court youtu.be doit être accepté."""
        a = ActivityCreate(**self.VALID_BASE, url="https://youtu.be/dQw4w9WgXcQ")
        assert a.url == "https://youtu.be/dQw4w9WgXcQ"

    def test_static_path_with_extension_accepted(self):
        """Un chemin /static/ avec une extension de fichier doit être accepté."""
        a = ActivityCreate(**self.VALID_BASE, url="/static/pdf/exercice.pdf")
        assert a.url == "/static/pdf/exercice.pdf"

    def test_static_audio_path_accepted(self):
        """Un chemin /static/audios/ doit être accepté."""
        a = ActivityCreate(**self.VALID_BASE, url="/static/audios/relaxation.mp3")
        assert a.url == "/static/audios/relaxation.mp3"

    def test_url_none_accepted(self):
        """Une URL None doit être acceptée (champ optionnel)."""
        a = ActivityCreate(**self.VALID_BASE, url=None)
        assert a.url is None

    def test_url_empty_string_becomes_none(self):
        """Une chaîne vide doit être convertie en None."""
        a = ActivityCreate(**self.VALID_BASE, url="")
        assert a.url is None

    def test_static_path_without_leading_slash_rejected(self):
        """Un chemin statique sans slash initial doit être refusé."""
        with pytest.raises(ValidationError):
            ActivityCreate(**self.VALID_BASE, url="static/pdf/fichier.pdf")

    def test_static_directory_without_extension_rejected(self):
        """Un chemin statique sans extension (dossier seul) doit être refusé."""
        with pytest.raises(ValidationError):
            ActivityCreate(**self.VALID_BASE, url="/static/pdf/")

    def test_arbitrary_string_rejected(self):
        """Une chaîne quelconque sans protocole ni chemin /static/ doit être refusée."""
        with pytest.raises(ValidationError):
            ActivityCreate(**self.VALID_BASE, url="pas-une-url-valide")

    def test_update_invalid_url_rejected(self):
        """ActivityUpdate doit aussi rejeter une URL invalide."""
        with pytest.raises(ValidationError):
            ActivityUpdate(url="static/pdf/")
