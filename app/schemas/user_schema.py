from pydantic import BaseModel

# Schema du JSON qu'on renvoie
# Le schéma permet de filtrer ce que le JSON renvoie, par exemple, il ne renverra pas le MDP
# Il gère aussi tout ce qui est champ VIDE dans un post par exemple

class UserSchema(BaseModel):
    name: str
    surname: str
    email: str
    password: str
    phone: str | None = None
    photo: str | None = None
    description: str | None = None
    role_id: int = 1

    # il faut lui dire de lire tous les attributs de l'objet user, autrement il attend un dictionnaire
    # mais le db.queryAll() renvoie un objet donc pas facile
    class Config:
        from_attributes = True