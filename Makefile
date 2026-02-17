all: scripts

config: .config/zsh/*.*
	@mkdir -p $(HOME)/.config/zsh
	@for file in .config/zsh/*.*; do \
		cp "$$file" "$(HOME)/.config/zsh/$${name%.*}"; \
	done
	@echo "Config installed to $(HOME)/.config/zsh"

scripts: bin/*.*
	@mkdir -p $(HOME)/bin
	@for file in bin/*.*; do \
		chmod +x "$$file"; \
		name=$$(basename "$$file"); \
		cp "$$file" "$(HOME)/bin/$${name%.*}"; \
	done
	@echo "Scripts installed to $(HOME)/bin"

.PHONY: all config scripts