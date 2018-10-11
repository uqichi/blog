POSTS      := $(wildcard content/posts/*.md)
POST_FILE  := `date +'%y%m%d%H%M%S'`

.DEFAULT_GOAL := help

list: ## List all posts
	@$(foreach val, $(POSTS), echo $(notdir $(val));)

new: ## Add new post
	@read -p "Enter post name: " f; \
	if [ -z $${f} ]; then FILE="posts/$(POST_FILE).md"; \
	else FILE="posts/$${f}.md"; \
	fi; \
	hugo new $${FILE}

edit: ## Edit specific post
	@nvim `ls -d $(POSTS) | peco`

deploy: ## Deploy posts
	@sh deploy.sh

pull: ## Pull changes
	@sh pull.sh

server: ## Run local server
	@hugo server -wD

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Aliases
ls: list
n:  new
e:  edit
s:  server
