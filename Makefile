POSTS := $(wildcard content/posts/*.md)

.PHONY: list new edit upmod server help

.DEFAULT_GOAL := help

list: ## List posts
	@$(foreach val, $(POSTS), echo $(notdir $(val));)

new: ## Add new post
	@test -n "$(title)"
	hugo new posts/$(title).md

edit: ## Edit post
	@nvim `ls -d $(POSTS) | peco`

upmod: ## Update sub modules to the latest version
	@git submodule update --rebase --remote

server: ## Run local server including content marked as draft
	hugo server -wD

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Aliases
l: list
n:  new
e:  edit
s:  server
