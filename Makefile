# === Makefile for full-stack project ===

.PHONY: up down build restart logs frontend backend

# Build and start all services
up:
	docker-compose up --build

# Stop all running containers
down:
	docker-compose down

# Rebuild without starting
build:
	docker-compose build

# Restart containers
restart:
	docker-compose down && docker-compose up --build

# Tail logs
logs:
	docker-compose logs -f

# Start only the frontend
frontend:
	docker-compose up --build frontend

# Start only the backend (if added later)
backend:
	docker-compose up --build backend
