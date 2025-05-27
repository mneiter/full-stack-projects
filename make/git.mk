# ==============================
# Git History Utilities (Git Bash)
# ==============================

.PHONY: rollback-main rollback-one-commit git-back git-help

# Checkout the previous commit (HEAD^)
rollback-one-commit:
	@git checkout HEAD^ && echo "Rolled back to previous commit"

# Return to the main branch
rollback-main:
	@git checkout main && echo "Returned to main branch"

# Checkout N commits back from HEAD
# Usage: make git-back N=3
git-back:
	@if [ -z "$(N)" ]; then \
		echo "Please provide how many commits to go back using N=<number>"; \
		exit 1; \
	else \
		echo "Checking out HEAD~$(N)..."; \
		git checkout HEAD~$(N); \
	fi

# Show available Git rollback commands
git-help:
	@echo "Available Git rollback commands:"
	@echo "  make rollback-one-commit       - Checkout previous commit (HEAD^)"
	@echo "  make rollback-main             - Return to 'main' branch"
	@echo "  make git-back N=<number>       - Checkout N commits back from HEAD"
