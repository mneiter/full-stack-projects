# === Makefile for full-stack project ===

.PHONY: help up down build restart logs frontend backend clean prune

# Show all available commands
help:
	@echo "Available make commands:"
	@echo "  make up        - Build and start all services (frontend, backend, mongo)"
	@echo "  make down      - Stop all services"
	@echo "  make build     - Build containers without running them"
	@echo "  make restart   - Restart project with rebuild"
	@echo "  make logs      - Tail logs from all containers"
	@echo "  make frontend  - Run only the frontend service"
	@echo "  make backend   - Run only the backend service"
	@echo "  make clean     - Remove volumes and node_modules"
	@echo "  make prune     - Deep clean Docker: remove all unused data"

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

clean:
	@echo "Cleaning Docker volumes and node_modules..."
	-docker-compose down -v
	@if [ -d "./frontend/node_modules" ]; then rm -rf ./frontend/node_modules; fi
	@if [ -d "./backend/node_modules" ]; then rm -rf ./backend/node_modules; fi

prune:
	docker system prune -af --volumes
