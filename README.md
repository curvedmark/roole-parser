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

* `str` - String of Roole code
* `options` - Object literal supports the following options:
	* `filename` - Absolute path of the file that contains this Roole code. If it's a path of an directory (e.g., the code comes from stdin), it should end with `/`.