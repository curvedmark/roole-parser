parser: lib/generatedParser.js

lib/generatedParser.js: lib/grammar.pegjs | node_modules
	node_modules/.bin/pegjs --cache --allowed-start-rules stylesheet,selector,selectorList,mediaQuery,mediaQueryList,list $< $@

node_modules:
	npm install

.PHONY: parser