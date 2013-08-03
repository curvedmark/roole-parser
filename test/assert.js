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

exports.failAt = function (str, opts, loc) {
	if (!loc) {
		loc = opts;
		opts = null;
	}

	try {
		parser.parse(str, opts);
	} catch (err) {
		if (!err.loc) throw err;
		assert.strictEqual(err.loc.line, loc.line, "failed at line " + err.loc.line + " instead of " + loc.line);
		assert.strictEqual(err.loc.column, loc.column, "failed at column " + err.loc.column + " instead of " + loc.column);
		assert.strictEqual(err.loc.start, loc.start, "failed at offset " + err.loc.start + " instead of " + loc.start);
		return;
	}
	throw new Error('no error was thrown');
};