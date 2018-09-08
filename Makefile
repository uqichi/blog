POSTS      := $(wildcard content/posts/*.md)
POST_FILE  := `date +'%y%m%d%H%M%S'`

.DEFAULT_GOAL := help

.PHONY: list
list: ## List all posts
	@$(foreach val, $(POSTS), echo $(notdir $(val));)

.PHONY: post
post: ## Add new post
	@read -p "Enter post name: " f; \
	if [ -z $${f} ]; then FILE="posts/$(POST_FILE).md"; \
	else FILE="posts/$${f}.md"; \
	fi; \
	hugo new $${FILE}

.PHONY: deploy
deploy: ## Deploy posts
	@sh deploy.sh

.PHONY: pull
pull: ## Pull changes
	@sh pull.sh

.PHONY: server
server: ## Run local server
	@hugo server -wD

.PHONY: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

