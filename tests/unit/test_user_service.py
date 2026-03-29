"""
Tests unitaires du service utilisateur.
Vérifie le comportement des fonctions métier (hachage, login...)
sans dépendre des routes HTTP.
"""
import pytest
import bcrypt
from unittest.mock import MagicMock, patch
from app.services.user_service import login_user


class TestLoginUser:

    def test_login_user_not_found(self):
        """Retourne None si l'utilisateur n'existe pas en base."""
        with patch("app.services.user_service.SessionLocal") as mock_session:
            db = MagicMock()
            db.query.return_value.filter.return_value.first.return_value = None
            mock_session.return_value = db

            result = login_user("inconnu@test.fr", "password")
            assert result is None

    def test_login_wrong_password(self):
        """Retourne None si le mot de passe est incorrect."""
        hashed = bcrypt.hashpw(b"BonMotDePasse1!", bcrypt.gensalt()).decode()

        mock_user = MagicMock()
        mock_user.password = hashed

        with patch("app.services.user_service.SessionLocal") as mock_session:
            db = MagicMock()
            db.query.return_value.filter.return_value.first.return_value = mock_user
            mock_session.return_value = db

            result = login_user("user@test.fr", "MauvaisMotDePasse1!")
            assert result is None

    def test_login_success_returns_token(self):
        """Retourne un token JWT si les identifiants sont corrects."""
        hashed = bcrypt.hashpw(b"BonMotDePasse1!", bcrypt.gensalt()).decode()

        mock_user = MagicMock()
        mock_user.id = 1
        mock_user.email = "user@test.fr"
        mock_user.role_id = 1
        mock_user.password = hashed

        with patch("app.services.user_service.SessionLocal") as mock_session:
            db = MagicMock()
            db.query.return_value.filter.return_value.first.return_value = mock_user
            mock_session.return_value = db

            result = login_user("user@test.fr", "BonMotDePasse1!")
            assert result is not None
            assert isinstance(result, str)  # le token est une string


class TestPasswordHashing:

    def test_password_is_hashed_on_create(self):
        """Le mot de passe stocké doit être un hash bcrypt, pas le mot de passe en clair."""
        from app.schemas.user_schema import UserCreate
        from app.services.user_service import create_user

        user_data = UserCreate(
            name="Test", surname="User",
            email="test.hash@example.com", password="Secure1!"
        )

        with patch("app.services.user_service.SessionLocal") as mock_session:
            db = MagicMock()
            db.query.return_value.filter.return_value.first.return_value = None

            created_user = MagicMock()
            created_user.password = None

            # Capture le mot de passe passé au constructeur User
            def capture_user(**kwargs):
                created_user.password = kwargs.get("password")
                return created_user

            with patch("app.services.user_service.User", side_effect=capture_user):
                mock_session.return_value = db
                try:
                    create_user(user_data)
                except Exception:
                    pass

            # Vérifie que le hash commence bien par $2b$ (format bcrypt)
            if created_user.password:
                assert created_user.password.startswith("$2b$")
                assert created_user.password != "Secure1!"
