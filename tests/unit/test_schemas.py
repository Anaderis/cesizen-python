"""
Tests unitaires des schémas Pydantic.
Vérifie que les validateurs acceptent ou rejettent les bonnes valeurs,
sans toucher à la base de données.
"""
import pytest
from pydantic import ValidationError
from app.schemas.user_schema import UserCreate

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
        assert user.email == "aliceexample.com"

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
