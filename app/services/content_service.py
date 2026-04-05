from app.models.content import ArticleSante, Activity, Category, Format, Favorites
from app.database import SessionLocal
from sqlalchemy.orm import joinedload


# ========================
# ARTICLES
# ========================

def get_all_articles():
    db = SessionLocal()
    try:
        return db.query(ArticleSante).options(joinedload(ArticleSante.category)).all()
    finally:
        db.close()


def get_article_by_id(article_id: int):
    db = SessionLocal()
    try:
        return db.query(ArticleSante).options(joinedload(ArticleSante.category)).filter(ArticleSante.id == article_id).first()
    finally:
        db.close()


def get_articles_by_category(category_id: int):
    db = SessionLocal()
    try:
        return db.query(ArticleSante).options(joinedload(ArticleSante.category)).filter(ArticleSante.category_id == category_id).all()
    finally:
        db.close()


def create_article(article_data):
    db = SessionLocal()
    try:
        new_article = ArticleSante(
            title=article_data.title,
            description=article_data.description,
            publish_date=article_data.publish_date,
            active=article_data.active,
            category_id=article_data.category_id,
        )
        db.add(new_article)
        db.commit()
        db.refresh(new_article)
        return new_article
    finally:
        db.close()


def update_article(article_id: int, article_data):
    db = SessionLocal()
    try:
        article = db.query(ArticleSante).filter(ArticleSante.id == article_id).first()
        if not article:
            return None
        fields = article_data.model_dump(exclude_none=True)
        for field, value in fields.items():
            setattr(article, field, value)
        db.commit()
        return db.query(ArticleSante).options(joinedload(ArticleSante.category)).filter(ArticleSante.id == article_id).first()
    finally:
        db.close()


def delete_article(article_id: int):
    db = SessionLocal()
    try:
        article = db.query(ArticleSante).filter(ArticleSante.id == article_id).first()
        if not article:
            return None
        db.delete(article)
        db.commit()
        return article
    finally:
        db.close()


# ========================
# ACTIVITIES
# ========================

def get_all_activities():
    """Retourne uniquement les activités actives (usage front utilisateur)."""
    db = SessionLocal()
    try:
        return db.query(Activity).options(joinedload(Activity.category), joinedload(Activity.format)).filter(Activity.active == True).all()
    finally:
        db.close()


def get_all_activities_admin():
    """Retourne toutes les activités y compris inactives (usage back office admin)."""
    db = SessionLocal()
    try:
        return db.query(Activity).options(joinedload(Activity.category), joinedload(Activity.format)).all()
    finally:
        db.close()


def get_activity_by_id(activity_id: int):
    db = SessionLocal()
    try:
        return db.query(Activity).options(joinedload(Activity.category), joinedload(Activity.format)).filter(Activity.id == activity_id).first()
    finally:
        db.close()


def get_activities_by_category(category_id: int):
    db = SessionLocal()
    try:
        return db.query(Activity).options(joinedload(Activity.category), joinedload(Activity.format)).filter(Activity.category_id == category_id).all()
    finally:
        db.close()


def create_activity(activity_data):
    db = SessionLocal()
    try:
        new_activity = Activity(
            title=activity_data.title,
            description=activity_data.description,
            url=activity_data.url,
            duration=activity_data.duration,
            active=activity_data.active,
            category_id=activity_data.category_id,
            format_id=activity_data.format_id,
        )
        db.add(new_activity)
        db.commit()
        db.refresh(new_activity)
        # Recharge avec les relations pour éviter DetachedInstanceError
        return db.query(Activity).options(joinedload(Activity.category), joinedload(Activity.format)).filter(Activity.id == new_activity.id).first()
    finally:
        db.close()


def update_activity(activity_id: int, activity_data):
    db = SessionLocal()
    try:
        activity = db.query(Activity).filter(Activity.id == activity_id).first()
        if not activity:
            return None
        fields = activity_data.model_dump(exclude_none=True)
        for field, value in fields.items():
            setattr(activity, field, value)
        db.commit()
        return db.query(Activity).options(joinedload(Activity.category), joinedload(Activity.format)).filter(Activity.id == activity_id).first()
    finally:
        db.close()


def delete_activity(activity_id: int):
    db = SessionLocal()
    try:
        activity = db.query(Activity).filter(Activity.id == activity_id).first()
        if not activity:
            return None
        db.delete(activity)
        db.commit()
        return activity
    finally:
        db.close()


# ========================
# FAVORITES
# ========================

def add_favorite(user_id: int, activity_id: int):
    db = SessionLocal()
    try:
        # Vérifie que l'activité existe
        activity = db.query(Activity).filter(Activity.id == activity_id).first()
        if not activity:
            return None
        # Vérifie que le favori n'existe pas déjà
        existing = db.query(Favorites).filter(
            Favorites.user_id == user_id,
            Favorites.activity_id == activity_id
        ).first()
        if existing:
            return None
        favorite = Favorites(user_id=user_id, activity_id=activity_id)
        db.add(favorite)
        db.commit()
        return favorite
    finally:
        db.close()


def remove_favorite(user_id: int, activity_id: int):
    db = SessionLocal()
    try:
        favorite = db.query(Favorites).filter(
            Favorites.user_id == user_id,
            Favorites.activity_id == activity_id
        ).first()
        if not favorite:
            return None
        db.delete(favorite)
        db.commit()
        return favorite
    finally:
        db.close()


def get_user_favorites(user_id: int):
    db = SessionLocal()
    try:
        return (
            db.query(Activity)
            .options(joinedload(Activity.category), joinedload(Activity.format))
            .join(Favorites, Favorites.activity_id == Activity.id)
            .filter(Favorites.user_id == user_id)
            .all()
        )
    finally:
        db.close()


# ========================
# CATEGORIES
# ========================

def get_all_categories():
    db = SessionLocal()
    try:
        return db.query(Category).all()
    finally:
        db.close()


# ========================
# FORMATS
# ========================

def get_all_formats():
    db = SessionLocal()
    try:
        return db.query(Format).all()
    finally:
        db.close()
