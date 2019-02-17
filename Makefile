# Configuration for Make
MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := help
.PHONY: clean test repl example help
.SILENT:

# Executables used in this makefile
PULP := pulp --psc-package
PSCPACKAGE := psc-package
NODE := node
YARN := yarn

# Options to pass to pulp when building
BUILD_OPTIONS := -- --stash --censor-lib --strict

# Package manifest files
PACKAGEJSON := package.json
PSCPACKAGEJSON = psc-package.json

# Various input directories
SRCPATH := ./src
TESTPATH := ./test
DOCS := ./docs
EXAMPLESPATH := $(DOCS)/Examples
EXAMPLEPATH := $(EXAMPLESPATH)/$(EXAMPLE)

# Various output directories
OUTPUT := ./out
MODULES := ./node_modules
PSCPACKAGES := ./.psc-package
BUILD := $(OUTPUT)/build
OUTPUT_DOCS := $(OUTPUT)/docs
OUTPUT_EXAMPLE := $(OUTPUT)/examples/$(EXAMPLE)

# The entry point for the compiled example, if an EXAMPLE is specified
EXAMPLE_INDEX := $(OUTPUT_EXAMPLE)/index.js

# Globs that match all source files
SOURCES := $(SRCPATH)/**/*
TESTSOURCES := $(TESTPATH)/**/*
EXAMPLESOURCES := $(EXAMPLESPATH)/**/*

# Install node modules
$(MODULES): $(PACKAGEJSON)
	$(YARN) --cache-folder $(MODULES) install

# Install psc packages
$(PSCPACKAGES): $(PSCPACKAGEJSON)
	$(PSCPACKAGE) install

# Build the source files
$(BUILD): $(PSCPACKAGES) $(SOURCES) $(MODULES)
	$(PULP) build \
	  --src-path $(SRCPATH) \
	  --build-path $(BUILD) \
	  $(BUILD_OPTIONS)
	touch $(BUILD)
build: $(BUILD)

# Create the example output directory for the example in the environment
# variable EXAMPLE
$(OUTPUT_EXAMPLE):
	mkdir -p $(OUTPUT_EXAMPLE)

# Build the example specified by the environment variable EXAMPLE
$(EXAMPLE_INDEX): $(OUTPUT_EXAMPLE) $(BUILD) $(EXAMPLEPATH)/Main.purs $(MODULES)
	$(PULP) build \
	  --src-path $(EXAMPLEPATH) \
	  --include $(SRCPATH) \
	  --build-path $(BUILD) \
	  --main Examples.$(EXAMPLE).Main \
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
	$(MAKE) example \
	  EXAMPLE=$$([ $$out ] && ls -1 $(EXAMPLESPATH) | sed "$${out}q;d")
else
example: $(BUILD) $(EXAMPLE_INDEX)
	$(NODE) $(EXAMPLE_INDEX)
endif

# Run the test suite
test: $(BUILD) $(TESTSOURCES) $(EXAMPLESOURCES) $(MODULES)
	$(PULP) test \
	  --src-path $(SRCPATH) \
	  --test-path $(TESTPATH) \
	  --include $(EXAMPLESPATH) \
	  --build-path $(BUILD) \
	  $(BUILD_OPTIONS)

# Launch a repl with all modules loaded
repl: $(PSCPACKAGES) $(SOURCES) $(TESTSOURCES) $(EXAMPLESOURCES) $(MODULES)
	$(PULP) repl \
	  --include $(EXAMPLESPATH) \
	  --src-path $(SRCPATH) \
	  --test-path $(TESTPATH)

# Remove all make output from the source tree
clean:
	rm -rf $(OUTPUT) $(MODULES) $(PSCPACKAGES)

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
$(OUTPUT_DOCS): $(PSCPACKAGES) $(SOURCES) $(MODULES)
	$(PULP) docs \
	  --src-path $(SRCPATH)
	rm -rf $(OUTPUT_DOCS)
	mv generated-docs $(OUTPUT_DOCS)
docs: $(OUTPUT_DOCS)
