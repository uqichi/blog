POSTS := $(wildcard content/posts/*.md)

.PHONY: list new newfrom edit upmod server help

.DEFAULT_GOAL := help

list: ## List posts
	@$(foreach val, $(POSTS), echo $(notdir $(val));)

new: ## Add new post
	@if [ -z $(title) ]; then echo "Usage:\n\tmake new title=?"; exit 1; fi
	@hugo new posts/$(title).md

newfrom: ## Add new post from file
	@if [ -z $(title) ] || [ -z $(file) ]; then echo "Usage:\n\tmake newfrom title=? file=?"; exit 1; fi
	@if [ -e content/posts/$(title).md ]; then echo "Error: ${PWD}/content/posts/$(title).md already exists"; exit 1; fi
	@cat archetypes/posts.md $(file) > content/posts/$(title).md
	@echo ${PWD}/content/posts/$(title).md created

edit: ## Edit post
	@nvim `ls -d $(POSTS) | peco`

upmod: ## Update sub modules to the latest version
	git submodule update --rebase --remote

server: ## Run local server including content marked as draft
	hugo server -wD

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Aliases
l:  list
n:  new
nf: newfrom
e:  edit
up: upmod
s:  server
