# A UTILISER EN TEST SEULEMENT
# permet de remplir la DB

from faker import Faker
from app.database import SessionLocal
from app.models.user import User

fake = Faker("en_US")

def seed_users(n=10):
    db = SessionLocal()

    for _ in range(n):
        user = User(
            name=fake.first_name(),
            surname=fake.last_name(),
            email=fake.unique.email(),
            password="1234",
            phone=fake.phone_number(),
            photo = fake.url(),
            description=fake.text(),
            role_id=1
        )

        db.add(user)

    db.commit()
    db.close()

if __name__ == "__main__":
    seed_users(10)