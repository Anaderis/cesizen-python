from fastapi import APIRouter, Depends
from fastapi.responses import PlainTextResponse
from app.services.log_service import get_admin_logs
from app.dependencies import require_admin
from datetime import datetime, timezone

route = APIRouter(prefix="/logs", tags=["Logs"])


@route.get("/export", response_class=PlainTextResponse)
def export_admin_logs(_: dict = Depends(require_admin)):
    """Exporte les logs des actions CRUD effectuées par les administrateurs (fichier texte)."""
    logs = get_admin_logs()
    now = datetime.now(timezone.utc).strftime("%d/%m/%Y à %H:%M:%S")

    lines = [
        "=" * 60,
        "LOGS ADMINISTRATEUR — CESIZen",
        f"Généré le : {now} UTC",
        f"Nombre d'entrées : {len(logs)}",
        "=" * 60,
        "",
    ]

    for log in logs:
        date_str = log.date_action.strftime("%d/%m/%Y %H:%M:%S")
        lines.append(f"[{date_str}] (admin_id:{log.user_id}) {log.action}")
        if log.description:
            lines.append(f"  → {log.description}")
        lines.append("")

    if not logs:
        lines.append("Aucune action administrative enregistrée.")

    content = "\n".join(lines)

    return PlainTextResponse(
        content=content,
        headers={"Content-Disposition": f"attachment; filename=logs-admin-{datetime.now(timezone.utc).strftime('%Y-%m-%d')}.txt"},
    )