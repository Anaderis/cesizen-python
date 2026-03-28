from sqlalchemy import Column, Integer, String, Text, Boolean, Date, TIMESTAMP, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.database import Base


# ========================
# CATEGORY
# ========================
class Category(Base):
    __tablename__ = "category"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, nullable=False)

    articles = relationship("ArticleSante", back_populates="category")
    activity = relationship("Activity", back_populates="category")


# ========================
# FORMAT
# ========================
class Format(Base):
    __tablename__ = "format"

    id = Column(Integer, primary_key=True, index=True)
    type = Column(String(50), unique=True, nullable=False)

    activity = relationship("Activity", back_populates="format")


# ========================
# ARTICLE SANTE
# ========================
class ArticleSante(Base):
    __tablename__ = "article_sante"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text)        # courte accroche pour la liste d'articles
    content = Column(Text)            # contenu HTML complet affiché sur la page
    publish_date = Column(Date)
    active = Column(Boolean, default=True)
    category_id = Column(Integer, ForeignKey("category.id"), nullable=False)

    created_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc))

    #back populate fait le lien avec la "variable" articles de la classe Category 
    # donc il faut que ce soit le même nom de variable, ici category
    category = relationship("Category", back_populates="articles")


# ========================
# ACTIVITIES
# ========================
class Activity(Base):
    __tablename__ = "activity"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text)
    url = Column(String(500))
    duration = Column(String(20))
    active = Column(Boolean, default=True)

    category_id = Column(Integer, ForeignKey("category.id"), nullable=False)
    format_id = Column(Integer, ForeignKey("format.id"), nullable=False)

    created_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc))

    category = relationship("Category", back_populates="activity")
    format = relationship("Format", back_populates="activity")
    favorites = relationship("Favorites", back_populates="activity")


# ========================
# FAVORITES (Table jointeure entre User et Activity)
# ========================
class Favorites(Base):
    __tablename__ = "favorites"

    user_id = Column(Integer, ForeignKey("user.id"), primary_key=True)
    activity_id = Column(Integer, ForeignKey("activity.id"), primary_key=True)

    created_at = Column(TIMESTAMP, default=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="favorites")
    activity = relationship("Activity", back_populates="favorites")
