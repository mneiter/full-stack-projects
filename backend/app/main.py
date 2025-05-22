import os
from fastapi import FastAPI

root_path = os.getenv("APP_ROOT_PATH", "")
app = FastAPI(root_path=root_path)

@app.get("/ping")
def ping():
    return {"ping": "pong"}
