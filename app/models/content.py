from sqlalchemy import Column, Integer, String, Text, Boolean, Date, TIMESTAMP, ForeignKey
from sqlalchemy.orm import relationship, declarative_base
from datetime import datetime

Base = declarative_base()


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
    description = Column(Text)
    publish_date = Column(Date)
    active = Column(Boolean, default=True)
    category_id = Column(Integer, ForeignKey("category.id"), nullable=False)

    created_at = Column(TIMESTAMP, default=datetime.utcnow)

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
    active = Column(Boolean, default=True)

    category_id = Column(Integer, ForeignKey("category.id"), nullable=False)
    format_id = Column(Integer, ForeignKey("format.id"), nullable=False)

    created_at = Column(TIMESTAMP, default=datetime.utcnow)

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

    created_at = Column(TIMESTAMP, default=datetime.utcnow)

    user = relationship("User", back_populates="favorites")
    activity = relationship("Activity", back_populates="favorites")
