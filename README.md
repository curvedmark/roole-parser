# roole-parser

Take a string of [Roole](http://roole.org/) code, and output the ast.

## Example

```javascript
var parser = require('roole-parser');
var ast = parser.parse('body { margin: 0 }');
console.log(ast);
```

## API

```javascript
parser.parse(str, [options])
```

* `str` - A string of Roole code
* `options` - Object literal supports these options:
	* `filename` (default: `""`) - Absolute path of the file that contains this Roole code