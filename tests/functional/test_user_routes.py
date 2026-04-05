"""
Tests fonctionnels des routes utilisateur.
Vérifie les droits d'accès (admin, user, public) sur chaque endpoint.
"""
import pytest
from unittest.mock import patch
from types import SimpleNamespace


def fake_user(id=1, role_id=1):
    return SimpleNamespace(
        id=id, name="Alice", surname="Dupont",
        email="alice@test.fr", phone=None,
        photo=None, description=None,
        role_id=role_id, is_active=True
    )


class TestGetUsers:

    # En Admin donc ça marche 200
    def test_get_all_users_as_admin(self, client, admin_headers):
        """GET /users/ en tant qu'admin retourne la liste."""
        with patch("app.controllers.user_route.get_all_users", return_value=[fake_user()]):
            response = client.get("/api/users/", headers=admin_headers)
        assert response.status_code == 200

    # Pas en admin donc ça marche pas
    def test_get_all_users_as_user(self, client, user_headers):
        """GET /users/ en tant qu'utilisateur standard retourne 403."""
        response = client.get("/api/users/", headers=user_headers)
        assert response.status_code == 403

    # Pas de token donc ça marche pas
    def test_get_all_users_without_token(self, client):
        """GET /users/ sans token retourne 401."""
        response = client.get("/api/users/")
        assert response.status_code == 401


class TestCreateUser:

    def test_create_user_public(self, client):
        """POST /users/create est accessible sans token."""
        with patch("app.controllers.user_route.create_user", return_value=fake_user()):
            response = client.post("/api/users/create", json={
                "name": "Alice",
                "surname": "Dupont",
                "email": "alice.new@test.fr",
                "password": "Secure1!"
            })
        assert response.status_code == 200

    def test_create_user_invalid_email(self, client):
        """POST /users/create avec email invalide retourne 422."""
        response = client.post("/api/users/create", json={
            "name": "Alice",
            "surname": "Dupont",
            "email": "pas-un-email",
            "password": "Secure1!"
        })
        assert response.status_code == 422

    def test_create_user_weak_password(self, client):
        """POST /users/create avec mot de passe faible retourne 422."""
        response = client.post("/api/users/create", json={
            "name": "Alice",
            "surname": "Dupont",
            "email": "alice@test.fr",
            "password": "1234"
        })
        assert response.status_code == 422


class TestDeleteUser:

    def test_delete_user_as_admin(self, client, admin_headers):
        """DELETE /users/{id} en tant qu'admin retourne 200."""
        with patch("app.controllers.user_route.delete_user", return_value=fake_user(id=5)):
            response = client.delete("/api/users/5", headers=admin_headers)
        assert response.status_code == 200

    def test_delete_user_without_token(self, client):
        """DELETE /users/{id} sans token retourne 401."""
        response = client.delete("/api/users/5")
        assert response.status_code == 401


class TestGetFavorites:

    def test_get_favorites_with_token(self, client, user_headers):
        """GET /users/me/favorites avec token retourne 200."""
        with patch("app.controllers.user_route.get_user_favorites", return_value=[]):
            response = client.get("/api/users/me/favorites", headers=user_headers)
        assert response.status_code == 200

    def test_get_favorites_without_token(self, client):
        """GET /users/me/favorites sans token retourne 401."""
        response = client.get("/api/users/me/favorites")
        assert response.status_code == 401


class TestUpdateUser:

    def test_update_own_account_as_user(self, client, user_headers):
        """PUT /users/{id} comme user sur son propre compte (id=998) retourne 200."""
        with patch("app.controllers.user_route.update_user", return_value=fake_user(id=998)):
            response = client.put("/api/users/998", headers=user_headers, json={"name": "Bob"})
        assert response.status_code == 200

    def test_update_other_account_as_user(self, client, user_headers):
        """PUT /users/{id} comme user sur un autre compte retourne 403."""
        response = client.put("/api/users/5", headers=user_headers, json={"name": "Bob"})
        assert response.status_code == 403

    def test_update_any_account_as_admin(self, client, admin_headers):
        """PUT /users/{id} comme admin peut modifier n'importe quel compte (role, statut)."""
        with patch("app.controllers.user_route.update_user", return_value=fake_user(id=5, role_id=2)):
            response = client.put("/api/users/5", headers=admin_headers, json={
                "role_id": 2,
                "is_active": False
            })
        assert response.status_code == 200

    def test_update_without_token(self, client):
        """PUT /users/{id} sans token retourne 401."""
        response = client.put("/api/users/5", json={"name": "Bob"})
        assert response.status_code == 401


class TestDeactivateUser:

    def test_deactivate_own_account_as_user(self, client, user_headers):
        """PUT /users/deactivate/{id} comme user sur son propre compte (id=998) retourne 200."""
        with patch("app.controllers.user_route.update_user", return_value=fake_user(id=998)):
            response = client.put("/api/users/deactivate/998", headers=user_headers)
        assert response.status_code == 200

    def test_deactivate_other_account_as_user(self, client, user_headers):
        """PUT /users/deactivate/{id} comme user sur un autre compte retourne 403."""
        response = client.put("/api/users/deactivate/5", headers=user_headers)
        assert response.status_code == 403

    def test_deactivate_any_account_as_admin(self, client, admin_headers):
        """PUT /users/deactivate/{id} comme admin sur n'importe quel compte retourne 200."""
        with patch("app.controllers.user_route.update_user", return_value=fake_user(id=5)):
            response = client.put("/api/users/deactivate/5", headers=admin_headers)
        assert response.status_code == 200

    def test_deactivate_without_token(self, client):
        """PUT /users/deactivate/{id} sans token retourne 401."""
        response = client.put("/api/users/deactivate/5")
        assert response.status_code == 401
