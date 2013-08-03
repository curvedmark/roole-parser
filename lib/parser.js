var generatedParser = require('./generatedParser');

exports.parse = function (str, options) {
	if (!options) options = {};
	if (!options.filename) options.filename = '';

	try {
		return generatedParser.parse(str, options);
	} catch (err) {
		throw normalizeError(err, options);
	}
};

function normalizeError(err, options) {
	if (!err.line) throw err;

	var found = err.found;
	switch (found) {
	case '\r':
	case '\n':
		found = 'new line';
		break;
	default:
		found = !found ? 'end of file' : "'" + found + "'";
	}
	err.message = 'unexpected ' + found;

	err.loc = options.loc || {
		line: err.line,
		column: err.column,
		offset: err.offset,
		filename: options.filename,
	};

	throw err;
}