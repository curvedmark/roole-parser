# roole-parser

Take a string of Roole code, and output the ast.

## Installation

	npm install roole-parser

## Example

```javascript
var parser = require('roole-parser');
var ast = parser.parse('body { margin: 0 }');
console.log(ast);
```