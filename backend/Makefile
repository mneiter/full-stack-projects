# === Makefile for local FastAPI development ===

VENV := venv
PYTHON := $(VENV)/bin/python
PIP := $(VENV)/bin/pip
UVICORN := $(VENV)/bin/uvicorn

.PHONY: help venv install run debug update clean format lint

# Show available commands
help:
	@echo "Available commands:"
	@echo "  make venv      - Create virtual environment"
	@echo "  make install   - Install dependencies from requirements.txt"
	@echo "  make run       - Run FastAPI app locally with hot-reload"
	@echo "  make debug     - Run app with debugpy for VSCode attach"
	@echo "  make update    - Upgrade dependencies from requirements.txt"
	@echo "  make clean     - Remove __pycache__ and .pyc files"
	@echo "  make format    - Format code with black"
	@echo "  make lint      - Lint code with flake8"

# Create virtual environment
venv:
	python -m venv $(VENV)

# Install dependencies
install:
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

# Run app locally
run:
	$(UVICORN) app.main:app --reload

# Run app with debugpy (port 5678)
debug:
	$(PYTHON) -m debugpy --listen 5678 --wait-for-client -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload

# Upgrade all dependencies
update:
	$(PIP) install --upgrade -r requirements.txt

# Remove pycache and .pyc files
clean:
	find . -type d -name "__pycache__" -exec rm -r {} + || true
	find . -type f -name "*.pyc" -delete || true

# Format code
format:
	$(VENV)/bin/black .

# Lint code
lint:
	$(VENV)/bin/flake8 app/
