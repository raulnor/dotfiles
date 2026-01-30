all: scripts

scripts: bin/*.*
	@mkdir -p $(HOME)/bin
	@for file in bin/*.*; do \
		chmod +x "$$file"; \
		name=$$(basename "$$file"); \
		cp "$$file" "$(HOME)/bin/$${name%.*}"; \
	done
	@echo "Scripts installed to $(HOME)/bin"

.PHONY: all scripts