parser: lib/generatedParser.js

lib/generatedParser.js: lib/grammar.pegjs | node_modules
	node_modules/.bin/pegjs --allowed-start-rules stylesheet,selector,mediaQuery $< $@

node_modules:
	npm install

.PHONY: parser