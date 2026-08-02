.DEFAULT_GOAL := help

help:
	@echo "Run \`make install\` to install configs and scripts."

SYNC := rsync -rc --delete --out-format='  %o %n'

install: config scripts

config: nvim zsh

nvim: .config/nvim/*.*
	@mkdir -p $(HOME)/.config/nvim/
	@$(SYNC) .config/nvim/ $(HOME)/.config/nvim/

zsh: .config/zsh/*.*
	@mkdir -p $(HOME)/.config/zsh/
	@$(SYNC) .config/zsh/ $(HOME)/.config/zsh/

BIN := $(HOME)/bin
SRC := $(wildcard bin/*.*)
DST := $(addprefix $(BIN)/,$(basename $(notdir $(SRC))))

scripts: $(DST)

$(DST): | $(BIN)

$(BIN):
	@mkdir -p $@

$(BIN)/%: bin/%.py
	@install -v -m 755 $< $@
$(BIN)/%: bin/%.sh
	@install -v -m 755 $< $@
$(BIN)/%: bin/%.zsh
	@install -v -m 755 $< $@
$(BIN)/%: bin/%.exs
	@install -v -m 755 $< $@

.PHONY: help install config nvim zsh scripts