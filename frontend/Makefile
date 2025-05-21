# === Makefile for local Next.js development ===

.PHONY: help install dev build lint format update clean audit fix

# Show available commands
help:
	@echo "Available commands:"
	@echo "  make install   - Install npm dependencies"
	@echo "  make dev       - Start Next.js dev server"
	@echo "  make build     - Build for production"
	@echo "  make lint      - Run ESLint"
	@echo "  make format    - Format code with Prettier"
	@echo "  make update    - Update all npm packages"
	@echo "  make audit     - Check for vulnerabilities"
	@echo "  make fix       - Auto-fix vulnerabilities (force)"
	@echo "  make clean     - Delete node_modules and .next"

install:
	npm install

dev:
	npm run dev

build:
	npm run build

lint:
	npm run lint || true

format:
	npx prettier --write .

update:
	npx npm-check-updates -u
	npm install

audit:
	npm audit

fix:
	npm audit fix --force

clean:
	rm -rf node_modules .next
