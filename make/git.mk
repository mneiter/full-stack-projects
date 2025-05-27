
.PHONY: rollback-main rollback-one-commit

rollback-one-commit:
	@git checkout HEAD^ && echo "Rolled back to previous commit"

rollback-main:
	@git checkout main && echo "Returned to main branch"

.PHONY: git-back 

# Go N commits back. Usage: make git-back N=3
git-back:
	@if [ -z "$(N)" ]; then \
		echo "Please provide how many commits to go back using N=<number>"; \
		exit 1; \
	else \
		echo "Checking out HEAD~$(N)..."; \
		git checkout HEAD~$(N); \
	fi