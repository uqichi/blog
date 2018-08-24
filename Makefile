POSTS      := $(wildcard content/posts/*.md)

.DEFAULT_GOAL := help

.PHONY: list ## List all posts
list:
	@$(foreach val, $(POSTS), echo $(notdir $(val));)

.PHONY: post ## Add new post
post:
	@hugo new "posts/"`date +'%y.%m.%d-%H.%M.%S'`.md

.PHONY: deploy ## Deploy posts
deploy:
	@sh deploy.sh

.PHONY: help
help:
	@printf "Tools for \'$(notdir $(shell pwd))\' project.\\n\\nUsage:\\n\\n\\tmake command\\n\\nThe commands are:\\n\\n"
	@cat Makefile | grep '.PHONY' | grep '##' | grep -v '@cat' | tr '.PHONY:' ' ' | tr '##' ' '

