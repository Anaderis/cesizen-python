from fastapi import FastAPI
from app.routes import route

app = FastAPI()
app.include_router(route)