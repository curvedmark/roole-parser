var assert = require('assert');
var parser = require('..');

exports.parseTo = function (str, opts, ast) {
	if (!ast) {
		ast = opts;
		opts = null;
	}
	var output = parser.parse(str, opts)
	assert.deepEqual(output, ast);
};