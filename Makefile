.PHONY = test boilerplate

# Project variables
OUT_FILE = VirtualValue.rbxmx
TEST_FILE = VirtualValue-test.rbxlx
BOILERPLATE_FILE = VirtualValue-boilerplate.rbxlx

# Rojo
ROJO = rojo
ROJO_PROJECT_BUILD = default.project.json
ROJO_PROJECT_TEST = test.project.json
ROJO_PROJECT_BOILERPLATE = boilerplate.project.json

# Source directories
SRC = lib src
SRC_TEST = test
find_files = $(shell find $(dir) -type f)

# Dependencies
DEPS = lib/Modules/Modules.rbxmx

$(OUT_FILE) : $(DEPS) $(foreach dir,$(SRC), $(find_files)) $(ROJO_PROJECT_BUILD)
	$(ROJO) build $(ROJO_PROJECT_BUILD) --output $(OUT_FILE)

$(DEPS):
	$(MAKE) --directory=$(@D)

clean :
	$(RM) $(OUT_FILE)
	$(RM) $(TEST_FILE)
	$(RM) $(BOILERPLATE_FILE)

test : $(DEPS) $(foreach dir,$(SRC), $(find_files)) $(foreach dir,$(SRC_TEST), $(find_files)) $(ROJO_PROJECT_TEST)
	$(ROJO) build $(ROJO_PROJECT_TEST) --output $(TEST_FILE)

boilerplate : $(DEPS) $(foreach dir,$(SRC), $(find_files)) $(ROJO_PROJECT_BOILERPLATE)
	$(ROJO) build $(ROJO_PROJECT_BOILERPLATE) --output $(BOILERPLATE_FILE)
