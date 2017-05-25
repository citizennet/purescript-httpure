PULP := pulp
BOWER := bower
BOWERJSON := bower.json
SRCPATH := ./lib
TESTPATH := ./test
OUTPUT := ./output
BUILD := $(OUTPUT)/build
COMPONENTS := $(OUTPUT)/components
DOCS := $(OUTPUT)/docs
TESTMAIN := HTTPure.HTTPureSpec
SOURCES := $(SRCPATH)/**/*
TESTSOURCES := $(TESTPATH)/**/*
.PHONY: clean test

test: $(BUILD) $(TESTSOURCES)
	$(PULP) test --src-path $(SRCPATH) --build-path $(BUILD) --main $(TESTMAIN)

$(BUILD): $(COMPONENTS) $(SOURCES)
	$(PULP) build --src-path $(SRCPATH) --build-path $(BUILD)
	touch $(BUILD)

$(COMPONENTS): $(BOWERJSON)
	$(BOWER) install

clean:
	rm -rf $(OUTPUT)

$(DOCS): $(COMPONENTS) $(SOURCES)
	$(PULP) docs --src-path $(SRCPATH)
	rm -rf $(DOCS)
	mv generated-docs $(DOCS)

docs: $(DOCS)
build: $(BUILD)
