from fastapi import APIRouter, HTTPException, Depends
from app.schemas.content_schema import ActivityCreate, ActivityUpdate, ActivityOut
from app.services.content_service import (
    get_all_activities, get_all_activities_admin, get_activity_by_id, get_activities_by_category,
    create_activity, update_activity,
    add_favorite, remove_favorite
)
from app.dependencies import require_admin, require_user
from app.services.log_service import write_log

route = APIRouter(prefix="/activities", tags=["Activities"])

# Droits :
# - GET : public (tout le monde peut consulter les activités)
# - POST /create, PUT : admin uniquement
# - PUT /deactivate : admin uniquement (pas de DELETE)
# - POST /{id}/favorite, DELETE /{id}/favorite : utilisateur connecté


# GET : Toutes les activités actives → public
@route.get("/", response_model=list[ActivityOut])
def get_activities_endpoint():
    return get_all_activities()


# GET : Toutes les activités (y compris inactives) → admin uniquement (back office)
@route.get("/admin/all", response_model=list[ActivityOut])
def get_all_activities_admin_endpoint(_: dict = Depends(require_admin)):
    return get_all_activities_admin()


# GET : Activités par catégorie → public
@route.get("/category/{category_id}", response_model=list[ActivityOut])
def get_activities_by_category_endpoint(category_id: int):
    return get_activities_by_category(category_id)


# GET : Activité par ID → public
@route.get("/{id}", response_model=ActivityOut)
def get_activity_endpoint(id: int):
    activity = get_activity_by_id(id)
    if not activity:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    return activity


# POST : Créer une activité → admin uniquement
@route.post("/create")
def create_activity_endpoint(activity: ActivityCreate, current_user: dict = Depends(require_admin)):
    created = create_activity(activity)
    write_log(current_user["id"], "Création activité", f"ID:{created.id} - {created.title}")
    return {"message": "Activité créée", "activity": ActivityOut.model_validate(created)}


# PUT : Désactiver une activité → admin uniquement (pas de DELETE)
@route.put("/deactivate/{id}")
def deactivate_activity_endpoint(id: int, current_user: dict = Depends(require_admin)):
    deactivated = update_activity(id, ActivityUpdate(active=False))
    if not deactivated:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    write_log(current_user["id"], "Désactivation activité", f"ID:{id} - {deactivated.title}")
    return {"message": "Activité désactivée", "activity": ActivityOut.model_validate(deactivated)}


# PUT : Modifier une activité → admin uniquement
@route.put("/{id}")
def update_activity_endpoint(id: int, activity: ActivityUpdate, current_user: dict = Depends(require_admin)):
    updated = update_activity(id, activity)
    if not updated:
        raise HTTPException(status_code=404, detail="Activité non trouvée")
    write_log(current_user["id"], "Modification activité", f"ID:{id} - {updated.title}")
    return {"message": "Activité modifiée", "activity": ActivityOut.model_validate(updated)}


# POST : Ajouter une activité en favoris → utilisateur connecté
@route.post("/{id}/favorite")
def add_favorite_endpoint(id: int, current_user: dict = Depends(require_user)):
    result = add_favorite(current_user["id"], id)
    if not result:
        raise HTTPException(status_code=404, detail="Activité non trouvée ou déjà en favoris")
    return {"message": "Activité ajoutée aux favoris"}


# DELETE : Retirer une activité des favoris → utilisateur connecté
@route.delete("/{id}/favorite")
def remove_favorite_endpoint(id: int, current_user: dict = Depends(require_user)):
    result = remove_favorite(current_user["id"], id)
    if not result:
        raise HTTPException(status_code=404, detail="Favori non trouvé")
    return {"message": "Activité retirée des favoris"}
