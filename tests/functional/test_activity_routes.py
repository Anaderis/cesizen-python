"""
Tests fonctionnels des routes activités.
Vérifie les droits d'accès et le filtrage actif/inactif.
"""
import pytest
from unittest.mock import patch
from types import SimpleNamespace

# Ici on utilise SimpleNameSpace plutôt que MagicMock pour créer des objets d'activité factices,
# SimpleNamespace stocke des données (variables), MagicMock simule des comportements (fonctions).

def fake_activity(id=1, active=True):
    return SimpleNamespace(
        id=id, title="Méditation guidée",
        description="Une séance de méditation",
        url="https://www.youtube.com/embed/test",
        duration="10 min", active=active,
        category_id=1, format_id=1,
        category=SimpleNamespace(id=1, name="Méditation"),
        format=SimpleNamespace(id=1, type="Vidéo")
    )


class TestGetActivities:

    def test_get_activities_public(self, client):
        """GET /activities/ est accessible sans token."""
        with patch("app.controllers.activity_route.get_all_activities", return_value=[fake_activity()]):
            response = client.get("/api/activities/")
        assert response.status_code == 200

    def test_get_activities_admin_all(self, client, admin_headers):
        """GET /activities/admin/all retourne toutes les activités pour un admin."""
        with patch("app.controllers.activity_route.get_all_activities_admin", return_value=[
            fake_activity(id=1, active=True),
            fake_activity(id=2, active=False)
        ]):
            response = client.get("/api/activities/admin/all", headers=admin_headers)
        assert response.status_code == 200
        assert len(response.json()) == 2

    def test_get_activities_admin_all_as_user(self, client, user_headers):
        """GET /activities/admin/all en tant qu'utilisateur standard retourne 403."""
        response = client.get("/api/activities/admin/all", headers=user_headers)
        assert response.status_code == 403


class TestCreateActivity:

    def test_create_activity_as_admin(self, client, admin_headers):
        """POST /activities/create en tant qu'admin retourne 200."""
        with patch("app.controllers.activity_route.create_activity", return_value=fake_activity()):
            response = client.post("/api/activities/create", headers=admin_headers, json={
                "title": "Pilates",
                "duration": "30 min",
                "active": True,
                "category_id": 1,
                "format_id": 1
            })
        assert response.status_code == 200

    def test_create_activity_as_user(self, client, user_headers):
        """POST /activities/create en tant qu'utilisateur standard retourne 403."""
        response = client.post("/api/activities/create", headers=user_headers, json={
            "title": "Pilates",
            "active": True,
            "category_id": 1,
            "format_id": 1
        })
        assert response.status_code == 403

    def test_create_activity_without_token(self, client):
        """POST /activities/create sans token retourne 401."""
        response = client.post("/api/activities/create", json={
            "title": "Pilates",
            "active": True,
            "category_id": 1,
            "format_id": 1
        })
        assert response.status_code == 401


class TestDeactivateActivity:

    def test_deactivate_activity_as_admin(self, client, admin_headers):
        """PUT /activities/deactivate/{id} en tant qu'admin retourne 200."""
        with patch("app.controllers.activity_route.update_activity", return_value=fake_activity(active=False)):
            response = client.put("/api/activities/deactivate/1", headers=admin_headers)
        assert response.status_code == 200

    def test_no_delete_route_exists(self, client, admin_headers):
        """DELETE /activities/{id} ne doit pas exister (cahier des charges)."""
        response = client.delete("/api/activities/1", headers=admin_headers)
        assert response.status_code == 405  # Method Not Allowed
