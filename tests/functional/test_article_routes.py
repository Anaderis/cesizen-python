"""
Tests fonctionnels des routes articles.
Vérifie que les articles sont publics en lecture et protégés en écriture.
"""
import pytest
from unittest.mock import patch
from types import SimpleNamespace
from datetime import date


def fake_article(id=1):
    return SimpleNamespace(
        id=id, title="Gérer le stress au travail",
        description="Une courte description",
        content="<p>Contenu HTML de l'article</p>",
        publish_date=date.today(),
        active=True, category_id=1,
        category=SimpleNamespace(id=1, name="Stress")
    )


class TestGetArticles:

    def test_get_articles_public(self, client):
        """GET /articles/ est accessible sans token."""
        with patch("app.controllers.article_route.get_all_articles", return_value=[fake_article()]):
            response = client.get("/api/articles/")
        assert response.status_code == 200

    def test_get_article_by_id_public(self, client):
        """GET /articles/{id} est accessible sans token."""
        with patch("app.controllers.article_route.get_article_by_id", return_value=fake_article(id=1)):
            response = client.get("/api/articles/1")
        assert response.status_code == 200

    def test_get_article_not_found(self, client):
        """GET /articles/{id} avec un id inexistant retourne 404."""
        with patch("app.controllers.article_route.get_article_by_id", return_value=None):
            response = client.get("/api/articles/999")
        assert response.status_code == 404


class TestUpdateArticle:

    def test_update_article_as_admin(self, client, admin_headers):
        """PUT /articles/{id} en tant qu'admin retourne 200."""
        with patch("app.controllers.article_route.update_article", return_value=fake_article()):
            response = client.put("/api/articles/1", headers=admin_headers, json={
                "title": "Titre modifié"
            })
        assert response.status_code == 200

    def test_update_article_as_user(self, client, user_headers):
        """PUT /articles/{id} en tant qu'utilisateur standard retourne 403."""
        response = client.put("/api/articles/1", headers=user_headers, json={
            "title": "Titre modifié"
        })
        assert response.status_code == 403

    def test_no_create_route_exists(self, client, admin_headers):
        """POST /articles/create ne doit pas exister (cahier des charges)."""
        response = client.post("/api/articles/create", headers=admin_headers, json={
            "title": "Nouvel article",
            "category_id": 1
        })
        assert response.status_code == 405  # Method Not Allowed

    def test_no_delete_route_exists(self, client, admin_headers):
        """DELETE /articles/{id} ne doit pas exister (cahier des charges)."""
        response = client.delete("/api/articles/1", headers=admin_headers)
        assert response.status_code == 405  # Method Not Allowed
