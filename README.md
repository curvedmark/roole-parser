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

* `str` - string of Roole code
* `options` - hash object supports the following options:
	* `filename` (default: `''`) - file path of the Roole code, used is debugging