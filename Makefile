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

# Various input directories
SRCPATH := ./src
TESTPATH := ./test
OUTPUT := ./out
DOCS := ./docs
EXAMPLESPATH := $(DOCS)/Examples
EXAMPLEPATH := $(EXAMPLESPATH)/$(EXAMPLE)

# Various output directories
BUILD := $(OUTPUT)/build
COMPONENTS := $(OUTPUT)/components
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

# Install bower components
$(COMPONENTS): $(BOWERJSON)
	$(BOWER) install

# Build the source files
$(BUILD): $(COMPONENTS) $(SOURCES)
	$(PULP) build \
	  --src-path $(SRCPATH) \
	  --build-path $(BUILD) \
	  -- --stash --censor-lib --strict
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
	$(info Which example would you like to run?)
	$(info )
	$(info Available examples:)
	ls -1 $(EXAMPLESPATH) | cat -n
	read -rp " > " out; \
	out=$$(echo $$out | sed 's/[^0-9]*//g'); \
	$(MAKE) example EXAMPLE=$$([ $$out ] && ls -1 $(EXAMPLESPATH) | sed "$${out}q;d")
else
example: $(BUILD) $(EXAMPLE_INDEX)
	$(NODE) $(EXAMPLE_INDEX)
endif

# Run the test suite
test: $(BUILD) $(TESTSOURCES) $(EXAMPLESOURCES)
	$(PULP) test \
	  --src-path $(SRCPATH) \
	  --test-path $(TESTPATH) \
	  --include $(EXAMPLESPATH) \
	  --build-path $(BUILD) \
	  --main $(TESTMAIN) \
	  -- --stash --censor-lib --strict

# Launch a repl with all modules loaded
repl: $(COMPONENTS) $(SOURCES) $(TESTSOURCES) $(EXAMPLESOURCES)
	$(PULP) repl \
	  --include $(EXAMPLESPATH) \
	  --src-path $(SRCPATH) \
	  --test-path $(TESTPATH)

# Remove all make output from the source tree
clean:
	rm -rf $(OUTPUT)

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
$(OUTPUT_DOCS): $(COMPONENTS) $(SOURCES)
	$(PULP) docs \
	  --src-path $(SRCPATH)
	rm -rf $(OUTPUT_DOCS)
	mv generated-docs $(OUTPUT_DOCS)
docs: $(OUTPUT_DOCS)
