var assert = require('./assert');

describe('roole-parser', function () {
	it("should parse empty string", function () {
		assert.parseTo('', {
			type: 'stylesheet',
			comments: [],
			children: []
		});
	});

	it("should parse assignment", function () {
		assert.parseTo('$a = 1;', {
			type: 'stylesheet',
			comments: [],
			children: [{
				type: 'assignment',
				operator: '=',
				children: [{
					type: 'variable',
					children: ['a'],
					loc: {
						line: 1,
						column: 1,
						start: 0,
						end: 2,
						filename: ''
					}
				}, {
					type: 'number',
					children: [1],
					loc: {
						line: 1,
						column: 6,
						start: 5,
						end: 6,
						filename: ''
					}
				}],
				loc: {
					line: 1,
					column: 1,
					start: 0,
					end: 7,
					filename: ''
				}
			}]
		});
	});
});