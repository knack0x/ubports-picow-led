.PHONY: build install launch logs run

CLICKABLE ?= clickable

# Basic

build:
	$(CLICKABLE) build

install:
	$(CLICKABLE) install

launch:
	$(CLICKABLE) launch

logs:
	$(CLICKABLE) logs

# Quick Commands

run:
	make build
	make install
	make launch
