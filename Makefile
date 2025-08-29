# Makefile for installing the rconevents mod
.PHONY: install

# Paths
MOD_NAME = rconevents
SRC_DIR = $(CURDIR)/$(MOD_NAME)
DEST_DIR = /c/Users/david/Zomboid/mods/$(MOD_NAME)

# Default target: copy mod to destination
install:
	@echo "Installing $(MOD_NAME) to $(DEST_DIR)..."
	mkdir -p $(DEST_DIR)
	cp -r $(SRC_DIR)/* $(DEST_DIR)/
	@echo "Done."

# Clean installed copy
uninstall:
	@echo "Removing $(DEST_DIR)..."
	rm -rf $(DEST_DIR)

# Reinstall = uninstall + install
reinstall: uninstall install
