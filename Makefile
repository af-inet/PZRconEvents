# Makefile for installing the rconevents mod
.PHONY: install uninstall publish
.DEFAULT: install

# Paths
MOD_NAME = rconevents
SRC_DIR = $(CURDIR)/$(MOD_NAME)
DEST_DIR = /c/Users/david/Zomboid/mods/$(MOD_NAME)
PUB_DIR = /c/Users/david/Zomboid/Workshop/RconEvents/Contents/mods/$(MOD_NAME)
PUB_DIR = /c/Users/david/Zomboid/Workshop/RconEvents

# Default target: copy mod to destination
install:
	@echo "Installing $(MOD_NAME) to $(DEST_DIR)..."
	mkdir -p $(DEST_DIR)
	cp -r $(SRC_DIR)/* $(DEST_DIR)/
	@echo "Done."

publish:
	@echo "Installing $(MOD_NAME) to $(PUB_DIR)..."
	mkdir -p $(PUB_DIR)/Contents/mods/$(MOD_NAME)
	cp -r $(SRC_DIR)/* $(PUB_DIR)/Contents/mods/$(MOD_NAME)
	cp $(CURDIR)/workshop/preview.png $(PUB_DIR)
	cp $(CURDIR)/workshop/workshop.txt $(PUB_DIR)
	@echo "Done."

# Default target: copy mod to destination
# clean:
# 	@echo "Removing $(DEST_DIR)..."
# 	rm -f $(DEST_DIR)/**/*.lua
# 	@echo "Done."

# clean-publish:
# 	@echo "Removing $(PUB_DIR)..."
# 	rm -f $(PUB_DIR)/*.lua
# 	@echo "Done."


# Clean installed copy
uninstall:
	@echo "Removing $(DEST_DIR)..."
	rm -rf $(DEST_DIR)

# Reinstall = uninstall + install
reinstall: uninstall install
