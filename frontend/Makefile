# === Makefile for Next.js frontend ===

.PHONY: help install dev build lint format clean

help:
	@echo "Usage:"
	@echo "  make install     Install dependencies"
	@echo "  make dev         Run development server"
	@echo "  make build       Build for production"
	@echo "  make lint        Run ESLint"
	@echo "  make format      Format code with Prettier"
	@echo "  make clean       Remove .next and node_modules"

install:
	npm install

dev:
	npm run dev

build:
	npm run build

lint:
	npm run lint || echo "Linting completed with warnings or errors."

format:
	npx prettier --write .

clean:
	rm -rf node_modules .next
