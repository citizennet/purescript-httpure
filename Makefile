# Configuration for Make
MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := help
.PHONY: clean test repl example help
.SILENT:

# Executables used in this makefile
PULP := pulp
BOWER := bower
NODE := node
NPM := npm

# Package manifest files
BOWERJSON := bower.json
PACKAGEJSON := package.json

# Various input directories
SRCPATH := ./lib
TESTPATH := ./test
OUTPUT := ./output
DOCS := ./docs
EXAMPLESPATH := $(DOCS)/examples
EXAMPLEPATH := $(EXAMPLESPATH)/$(EXAMPLE)

# Various output directories
BUILD := $(OUTPUT)/build
COMPONENTS := $(OUTPUT)/components
NODE_MODULES := ./node_modules
OUTPUT_DOCS := $(OUTPUT)/docs
OUTPUT_EXAMPLE := $(OUTPUT)/examples/$(EXAMPLE)

# The entry point for the compiled example, if an EXAMPLE is specified
EXAMPLE_INDEX := $(OUTPUT_EXAMPLE)/index.js

# Globs that match all source files
SOURCES := $(SRCPATH)/**/*
TESTSOURCES := $(TESTPATH)/**/*
EXAMPLESOURCES := $(EXAMPLESPATH)/**/*

# This is the module name for the entry point for the test suite
TESTMAIN := HTTPure.HTTPureSpec

$(NODE_MODULES): $(PACKAGEJSON)
	$(NPM) install

# Install bower components
$(COMPONENTS): $(BOWERJSON)
	$(BOWER) install

# Build the source files
$(BUILD): $(COMPONENTS) $(NODE_MODULES) $(SOURCES)
	$(PULP) build \
	  --src-path $(SRCPATH) \
	  --build-path $(BUILD)
	touch $(BUILD)
build: $(BUILD)

# Create the example output directory for the example in the environment
# variable EXAMPLE
$(OUTPUT_EXAMPLE):
	mkdir -p $(OUTPUT_EXAMPLE)

# Build the example specified by the environment variable EXAMPLE
$(EXAMPLE_INDEX): $(OUTPUT_EXAMPLE) $(BUILD) $(EXAMPLEPATH)/Main.purs
	$(PULP) build \
	  --src-path $(EXAMPLEPATH) \
	  --include $(SRCPATH) \
	  --build-path $(BUILD) \
	  --main $(EXAMPLE) \
	  --to $(EXAMPLE_INDEX)

# Run the example specified by the environment variable EXAMPLE
ifeq ($(EXAMPLE),)
example:
	$(info You must supply a value in the environment variable EXAMPLE)
	$(info )
	$(info Available examples:)
	ls -1 $(EXAMPLESPATH) | sed 's/^/ - /'
else
example: $(BUILD) $(EXAMPLE_INDEX)
	$(NODE) $(EXAMPLE_INDEX)
endif

# Run the test suite
test: $(BUILD) $(TESTSOURCES) $(EXAMPLESOURCES)
	$(PULP) test \
	  --src-path $(SRCPATH) \
	  --include $(EXAMPLESPATH) \
	  --build-path $(BUILD) \
	  --main $(TESTMAIN)

# Launch a repl with all modules loaded
repl: $(COMPONENTS) $(NODE_MODULES) $(SOURCES) $(TESTSOURCES) $(EXAMPLESOURCES)
	$(PULP) repl \
	  --include $(EXAMPLESPATH) \
	  --src-path $(SRCPATH) \
	  --test-path $(TESTPATH)

# Remove all make output from the source tree
clean:
	rm -rf $(OUTPUT)
	rm -rf $(NODE_MODULES)

# Print out a description of all the supported tasks
help:
	$(info HTTPure make utility)
	$(info )
	$(info Usage: make [ test | docs | example | repl | clean | help ])
	$(info )
	$(info - make test        Run the test suite)
	$(info - make docs        Build the documentation into $(OUTPUT_DOCS))
	$(info - make example     Run the example in environment variable EXAMPLE)
	$(info - make repl        Launch a repl with all project code loaded)
	$(info - make clean       Remove all build files)
	$(info - make help        Print this help)

# Build the documentation
$(OUTPUT_DOCS): $(COMPONENTS) $(NODE_MODULES) $(SOURCES)
	$(PULP) docs \
	  --src-path $(SRCPATH)
	rm -rf $(OUTPUT_DOCS)
	mv generated-docs $(OUTPUT_DOCS)
docs: $(OUTPUT_DOCS)
