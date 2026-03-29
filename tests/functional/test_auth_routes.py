"""
Tests fonctionnels des routes d'authentification.
Vérifie le comportement des endpoints HTTP de login.
"""
import pytest
from unittest.mock import patch


class TestLoginRoute:

    def test_login_success(self, client):
        """POST /auth/login avec de bons identifiants retourne un token."""
        fake_token = "eyJhbGciOiJIUzI1NiJ9.test.token"

        with patch("app.controllers.login_route.login_user", return_value=fake_token):
            response = client.post("/api/auth/login", json={
                "email": "admin@test.fr",
                "password": "Admin1!"
            })

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["access_token"] == fake_token

    def test_login_wrong_credentials(self, client):
        """POST /auth/login avec de mauvais identifiants retourne 401."""
        with patch("app.controllers.login_route.login_user", return_value=None):
            response = client.post("/api/auth/login", json={
                "email": "inconnu@test.fr",
                "password": "MauvaisMotDePasse1!"
            })

        assert response.status_code == 401

    def test_login_missing_fields(self, client):
        """POST /auth/login sans email retourne 422 (validation Pydantic)."""
        response = client.post("/api/auth/login", json={
            "password": "Admin1!"
        })
        assert response.status_code == 422
