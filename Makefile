POSTS      := $(wildcard content/posts/*.md)
POST_FILE  := `date +'%y%m%d%H%M%S'`

.DEFAULT_GOAL := help

.PHONY: list ## List all posts
list:
	@$(foreach val, $(POSTS), echo $(notdir $(val));)

.PHONY: post ## Add new post
post:
	@read -p "Enter post name: " f; \
	if [ -z $${f} ]; then FILE="posts/$(POST_FILE).md"; \
	else FILE="posts/$${f}.md"; \
	fi; \
	hugo new $${FILE}

.PHONY: deploy ## Deploy posts
deploy:
	@sh deploy.sh

.PHONY: server ## Run local server
server:
	@hugo server -wD

.PHONY: help
help:
	@printf "Tools for \'$(notdir $(shell pwd))\' project.\\n\\nUsage:\\n\\n\\tmake command\\n\\nThe commands are:\\n\\n"
	@cat Makefile | grep '.PHONY' | grep '##' | grep -v '@cat' | tr '.PHONY:' ' ' | tr '##' ' '

