import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


root_path = os.getenv("APP_ROOT_PATH", "")
app = FastAPI(root_path=root_path)

origins = [
    "http://localhost:3000",
    "http://dev.localhost",
    "https://dev.localhost",
    "http://staging.localhost",
    "https://staging.localhost",
    "http://prod.localhost",
    "https://prod.localhost",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/ping")
def ping():
    return {"ping": "pong"}
