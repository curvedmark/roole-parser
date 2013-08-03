var assert = require('assert');
var parser = require('..');

exports.parseTo = function (str, opts, ast) {
	if (!ast) {
		ast = opts;
		opts = null;
	}
	assert.deepEqual(parser.parse(str, opts), ast);
}