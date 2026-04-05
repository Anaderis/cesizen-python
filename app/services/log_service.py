from app.models.user import Log, User
from app.database import SessionLocal
from datetime import datetime, timezone


def write_log(user_id: int, action: str, description: str = ""):
    """Enregistre une action administrative en base."""
    db = SessionLocal()
    try:
        entry = Log(
            user_id=user_id,
            action=action,
            description=description,
            date_action=datetime.now(timezone.utc),
        )
        db.add(entry)
        db.commit()
    finally:
        db.close()


def get_admin_logs() -> list[Log]:
    """Retourne tous les logs des comptes administrateur, du plus ancien au plus récent."""
    db = SessionLocal()
    try:
        return (
            db.query(Log)
            .join(User, User.id == Log.user_id)
            .filter(User.role_id == 2)
            .order_by(Log.date_action.asc())
            .all()
        )
    finally:
        db.close()