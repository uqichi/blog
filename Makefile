POSTS := $(wildcard content/posts/*.md)

.PHONY: list new edit deploy pull server help

.DEFAULT_GOAL := help

list: ## List all posts
	@$(foreach val, $(POSTS), echo $(notdir $(val));)

new: ## Add new post
	@test -n "$(FILE)"
	hugo new posts/$(FILE).md

edit: ## Edit specific post
	@nvim `ls -d $(POSTS) | peco`

deploy: ## Deploy posts
	@sh deploy.sh

pull: ## Pull remote changes
	@sh pull.sh

server: ## Run local server including content marked as draft
	hugo server -wD

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Aliases
l: list
n:  new
e:  edit
s:  server
