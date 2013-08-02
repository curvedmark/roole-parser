var parser = require('./parser');

exports.parse = function (str, options) {
	if (!options) options = {};

	try {
		return parser.parse(str, options );
	} catch (err) {

		throw normalizeError(err, options);
	}
};

function normalizeError(err, options) {
	if (!err.line) return err;

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
}