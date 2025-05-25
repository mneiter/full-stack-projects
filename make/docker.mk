
# ==============================
# 🐳 Docker Compose Section
# ==============================

.PHONY: up down build restart logs frontend backend

up:
	docker-compose up --build

down:
	docker-compose down

build:
	docker-compose build

restart:
	docker-compose down && docker-compose up --build

logs:
	docker-compose logs -f

frontend:
	docker-compose up --build frontend

backend:
	docker-compose up --build backend
