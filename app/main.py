from sys import prefix

from fastapi import FastAPI
from app.controllers.user_route import route

app = FastAPI()
app.include_router(route, prefix="/api")