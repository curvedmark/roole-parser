{
	var indent = '';
	var loc = options.loc ? function() {
		return options.loc;
	} : function () {
		var start = offset();
		var end = start + text().length;

		return {
			line: line(),
			column: column(),
			start: start,
			end: end,
			filename: options.filename
		};
	};

	function shallowFlatten(arr) {
		var flattened = [];
		return flattened.concat.apply(flattened, arr);
	}
}

stylesheet
	= comments:_c rules:rules _ {
		return {
			type: 'stylesheet',
			comments: comments,
			children: rules
		};
	}

rules
	= rule*

rule
	= comments:_c ruleset:ruleset { ruleset.comments = comments; return ruleset; }
	/ comments:_c prop:property { prop.comments = comments; return prop; }
	/ comments:_c media:media { media.comments = comments; return media; }
	/ comments:_c imp:import { imp.comments = comments; return imp; }
	/ _ assign:assignment { return assign; }
	/ _ extend:extend { return extend; }
	/ _ voidNode:void { return voidNode; }
	/ _ block:block { return block; }
	/ _ ifNode:if { return ifNode; }
	/ _ forNode:for { return forNode; }
	/ _ mixin:mixin { return mixin; }
	/ _ returnNode:return { return returnNode; }
	/ comments:_c kfs:keyframes { kfs.comments = comments; return kfs; }
	/ comments:_c ff:fontFace { ff.comments = comments; return ff; }
	/ comments:_c page:page { page.comments = comments; return page; }
	/ comments:_c charset:charset { charset.comments = comments; return charset; }
	/ _ module:module { return module; }
	/ _ stmt:statement { return stmt; }

ruleset
	= selList:selectorList _ ruleList:ruleList {
		return {
			type: 'ruleset',
			children: [selList, ruleList],
			loc: loc()
		};
	}

selectorList
	= first:selector rest:(_ ',' _ s:selector { return s; })* {
		rest.unshift(first);
		return {
			type: 'selectorList',
			children: rest,
			loc: loc()
		};
	}

selector
	= comb:(c:nonSpaceCombinator _ { return c; })? sel:compoundSelector {
		if (comb) sel.unshift(comb);
		return {
			type: 'selector',
			children: sel,
			loc: loc()
		};
	}

compoundSelector
	= first:simpleSelector rest:(c:combinator s:simpleSelector {s.unshift(c); return s;})* {
		return rest.length ? first.concat(shallowFlatten(rest)) : first;
	}

combinator
	= _ comb:nonSpaceCombinator _ {
		return comb;
	}
	/ spaceCombinator

nonSpaceCombinator
	= value:[>+~] {
		return {
			type: 'combinator',
			children: [value],
			loc: loc()
		};
	}

spaceCombinator
	= s {
		return {
			type: 'combinator',
			children: [' '],
			loc: loc()
		};
	}

simpleSelector
	= first:(baseSelector / suffixSelector) rest:suffixSelector* {
		rest.unshift(first);
		return rest;
	}

baseSelector
	= selectorInterpolation
	/ typeSelector
	/ universalSelector
	/ ampersandSelector

suffixSelector
	= hashSelector
	/ classSelector
	/ attributeSelector
	/ negationSelector
	/ pseudoSelector

selectorInterpolation
	= value:variable {
		return {
			type: 'selectorInterpolation',
			children: [value],
			loc: loc()
		};
	}

typeSelector
	= value:identifier {
		return {
			type: 'typeSelector',
			children: [value],
			loc: loc()
		};
	}

universalSelector
	= '*' {
		return {
			type: 'universalSelector',
			loc: loc()
		};
	}

ampersandSelector
	= '&' value:partialIdentifier? {
		return {
			type: 'ampersandSelector',
			children: [value || null],
			loc: loc()
		};
	}

hashSelector
	= '#' value:identifier {
		return {
			type: 'hashSelector',
			children: [value],
			loc: loc()
		};
	}

classSelector
	= '.' value:identifier {
		return {
			type: 'classSelector',
			children: [value],
			loc: loc()
		};
	}

attributeSelector
	= '[' _ name:identifier rest:(_ o:$([$^*~|]? '=') _ l:list { return [o, l]; })? _ ']' {
		var node = {
			type: 'attributeSelector',
			children: [name],
			loc: loc()
		};
		if (rest) {
			node.operator = rest[0];
			node.children.push(rest[1]);
		}
		return node;
	}

negationSelector
	= ':not('i  _ arg:negationArgument _ ')' {
		return {
			type: 'negationSelector',
			children: [arg],
			loc: loc()
		};
	}

negationArgument
	= classSelector
	/ typeSelector
	/ attributeSelector
	/ pseudoSelector
	/ hashSelector
	/ universalSelector

pseudoSelector
	= ':' dc:':'? name:identifier arg:('(' _ a:pseudoArgument _ ')' { return a; })? {
		return {
			type: 'pseudoSelector',
			doubleColon: !!dc,
			children: [name, arg || null],
			loc: loc()
		};
	}

pseudoArgument
	= first:pseudoElement rest:(_ a:pseudoElement { return a; })* {
		rest.unshift(first);
		return {
			type: 'pseudoArgument',
			children: rest,
			loc: loc()
		};
	}

pseudoElement
	= [-+] / dimension / number / string / identifier

ruleList
	= '{' rules:rules _ '}' {
		return {
			type: 'ruleList',
			children: rules,
			loc: loc()
		};
	}

property
	= star:'*'? name:identifier _ ':' _ value:list _ priority:'!important'? _ semicolon {
		if (star) {
			if (name.type === 'identifier')
				name.children.unshift(star);
			else
				name = {
					type: 'identifier',
					children: [star, name],
					loc: loc()
				};
		}
		return {
			type: 'property',
			priority: priority || '',
			children: [name, value],
			loc: loc()
		};
	}

semicolon
	= &('}')
	/ ';' (_ ';')*

statement
	= list:list _ semicolon {
		return {
			type: 'statement',
			children: [list],
			loc: loc()
		};
	}

list
	= first:logicalOr rest:(separator logicalOr)+ {
		rest = shallowFlatten(rest);
		rest.unshift(first);
		return {
			type: 'list',
			children: rest,
			loc: loc()
		};
	}
	/ logicalOr

separator
	= _ commaSeparator:commaSeparator _ {
		return commaSeparator;
	}
	/ nonCommaSeparator

commaSeparator
	= value:',' {
		return {
			type: 'separator',
			children: [value],
			loc: loc()
		};
	}

nonCommaSeparator
	= value:('/' / s { return ' '; }) {
		return {
			type: 'separator',
			children: [value],
			loc: loc()
		};
	}

nonCommaList
	= first:logicalOr rest:(nonCommaSeparator logicalOr)+ {
		rest = shallowFlatten(rest);
		rest.unshift(first);
		return {
			type: 'list',
			children: rest,
			loc: loc()
		};
	}
	/ logicalOr

logicalOr
	= first:logicalAnd rest:(_ 'or'i _ e:logicalAnd { return e; })* {
		var node = first;
		rest.forEach(function(operand) {
			node = {
				type: 'binaryExpression',
				operator: 'or',
				children: [node, operand],
				loc: loc()
			};
		});
		return node;
	}

logicalAnd
	= first:equality rest:(_ 'and'i _ e:equality { return e; })* {
		var node = first;
		rest.forEach(function(operand) {
			node = {
				type: 'binaryExpression',
				operator: 'and',
				children: [node, operand],
				loc: loc()
			};
		});
		return node;
	}

equality
	= first:relational rest:((_ o:('isnt'i / 'is'i) _ { return o; }) relational)* {
		var node = first;
		rest.forEach(function(array) {
			var operator = array[0];
			var operand = array[1];
			node = {
				type: 'binaryExpression',
				operator: operator,
				children: [node, operand],
				loc: loc()
			};
		});
		return node;
	}

relational
	= first:range rest:((_ o:$([<>]'='?) _ { return o; }) range)* {
		var node = first;
		rest.forEach(function(array) {
			var operator = array[0];
			var operand = array[1];
			node = {
				type: 'binaryExpression',
				operator: operator,
				children: [node, operand],
				loc: loc()
			};
		});
		return node;
	}

range
	= from:additive _ ex:('..' e:'.'? { return !!e; }) _ to:additive {
		return {
			type: 'range',
			exclusive: ex,
			children: [from, to],
			loc: loc()
		};
	}
	/ additive

additive
	= first:multiplicative rest:((_ c:[-+] s { return c; } / [-+]) multiplicative)* {
		var node = first;
		rest.forEach(function(array) {
			var operator = array[0];
			var operand = array[1];
			node = {
				type: 'binaryExpression',
				operator: operator,
				children: [node, operand],
				loc: loc()
			};
		})
		return node;
	}

multiplicative
	= first:unary rest:((_ c:'/' s { return c; } / s c:'/' _ { return c; } / _ c:[*%] _ { return c; }) unary)* {
		var node = first;
		rest.forEach(function(array) {
			var operator = array[0];
			var operand = array[1];
			node = {
				type: 'binaryExpression',
				operator: operator,
				children: [node, operand],
				loc: loc()
			};
		});
		return node;
	}

unary
	= unit
	/ operator:[-+] operand:unit {
		return {
			type: 'unaryExpression',
			operator: operator,
			children: [operand],
			loc: loc()
		};
	}

unit
	= val:postfix unit:$('%' / rawIdentifier) {
		return {
			type: 'unit',
			unit: unit,
			children: [val],
			loc: loc()
		}
	}
	/ postfix

postfix
	= name:primary posts:(argumentList / accessor)* {
		var node = name;
		posts.forEach(function(post) {
			node = {
				type: post.type === 'argumentList' ? 'call' : 'member',
				children: [node, post],
				loc: loc()
			};
		})
		return node;
	}

argumentList
	= '(' _ args:args? _ ')' {
		return {
			type: 'argumentList',
			children: args || [],
			loc: loc()
		};
	}

args
	= first:nonCommaList rest:(_ ',' _ s:nonCommaList { return s; })* {
		rest.unshift(first);
		return rest;
	}

accessor
	= '[' _ range:range _ ']' {
		return range;
	}

primary
	= '(' _ list:list _ ')' {
		return list;
	}
	/ '[' _ list:(l:list _ { return l; })? ']' {
		var items;
		if (!list) items = [];
		else if (list.type === 'list' && !list.bracketed) items = list.children;
		else items = [list];

		return {
			type: 'list',
			bracketed: true,
			children: items,
			loc: loc()
		};
	}
	/ percentage
	/ dimension
	/ number
	/ color
	/ url
	/ function
	/ boolean
	/ null
	/ identifier
	/ string

identifier
	= first:identifierStart rest:(variable / interpolation / partialRawIdentifier)+ {
		if (Array.isArray(first)) rest = first.concat(rest);
		else rest.unshift(first);
		return {
			type: 'identifier',
			children: rest,
			loc: loc()
		};
	}
	/ value:rawIdentifier {
		return {
			type: 'identifier',
			children: [value],
			loc: loc()
		};
	}
	/ variable
	/ interpolation

identifierStart
	= rawIdentifier
	/ dash:'-'? variable:variable {
		return dash ? [dash, variable] : variable;
	}
	/ dash:'-'? interp:interpolation {
		return dash ? [dash, interp] : interp;
	}

partialIdentifier
	= values:(partialRawIdentifier / variable / interpolation)+ {
		return {
			type: 'identifier',
			children: values,
			loc: loc()
		};
	}

rawIdentifier
	= $('-'? [_a-z]i partialRawIdentifier?)

partialRawIdentifier
	= $([-_a-z0-9]i+)

interpolation
	= '{' _ variable:variable _ '}' {
		return variable;
	}

variable
	= '$' name:rawIdentifier {
		return {
			type: 'variable',
			children: [name],
			loc: loc()
		};
	}

string
	= "'" value:$(([^\n\r\f\\'] / '\\' .)*) "'" {
		return {
			type: 'string',
			quote: "'",
			children: [value],
			loc: loc()
		};
	}
	/ '"' values:($(([^\n\r\f\\"{$] / '\\' .)+) / variable / interpolation / '{')* '"' {
		if (!values.length) values.push('');
		return {
			type: 'string',
			quote: '"',
			children: values,
			loc: loc()
		};
	}

percentage
	= value:rawNumber '%' {
		return {
			type: 'percentage',
			children: [value],
			loc: loc()
		};
	}

dimension
	= value:rawNumber unit:rawIdentifier {
		return {
			type: 'dimension',
			children: [value, unit],
			loc: loc()
		};
	}

number
	= value:rawNumber {
		return {
			type: 'number',
			children: [value],
			loc: loc()
		};
	}

rawNumber = value:$([0-9]* '.' [0-9]+ / [0-9]+) {
		return +value
	}

color
	= '#' rgb:$[0-9a-z]i+ {
		if (rgb.length !== 3 && rgb.length !== 6) return
		return {
			type: 'color',
			children: [rgb],
			loc: loc()
		};
	}

function
	= '@function'i _ paramList:parameterList _ ruleList:ruleList {
		return {
			type: 'function',
			children: [paramList, ruleList],
			loc: loc()
		};
	}

parameterList
	= params:parameters restParam:(_ ',' _ p:restParameter { return p; })?{
		if (restParam) params.push(restParam);
		return {
			type: 'parameterList',
			children: params,
			loc: loc()
		};
	}
	/ restParam:restParameter? {
		var params = [];
		if (restParam) params.push(restParam);
		return {
			type: 'parameterList',
			children: params,
			loc: loc()
		};
	}

parameters
	= first:parameter rest:(_ ',' _ p:parameter { return p; })* {
		rest.unshift(first);
		return rest;
	}

parameter
	= variable:variable value:(_ '=' _ s:nonCommaList { return s; })? {
		return {
			type: 'parameter',
			children: [variable, value || null],
			loc: loc()
		};
	}

restParameter
	= '...' variable:variable {
		return {
			type: 'restParameter',
			children: [variable],
			loc: loc()
		};
	}

boolean
	= 'true'i {
		return {
			type: 'boolean',
			children: [true],
			loc: loc()
		};
	}
	/ 'false'i {
		return {
			type: 'boolean',
			children: [false],
			loc: loc()
		};
	}

null
	= 'null'i {
		return {
			type: 'null',
			loc: loc()
		};
	}

assignment
	= variable:variable accessors:accessor* _ operator:$([-+*/%?]? '=') _ value:list _ semicolon {
		var node = variable;
		accessors.forEach(function (accessor) {
			node = {
				type: 'member',
				children: [node, accessor],
				loc: variable.loc
			};
		});
		return {
			type: 'assignment',
			operator: operator,
			children: [node, value],
			loc: loc()
		};
	}

media
	= '@media'i _ mqList:mediaQueryList _ ruleList:ruleList {
		return {
			type: 'media',
			children: [mqList, ruleList],
			loc: loc()
		};
	}

mediaQueryList
	= first:mediaQuery rest:(_ ',' _ q:mediaQuery { return q; })* {
		rest.unshift(first);
		return {
			type: 'mediaQueryList',
			children: rest,
			loc: loc()
		};
	}

mediaQuery
	= first:(mediaInterpolation / mediaType / mediaFeature) rest:(_ 'and'i _ m:(mediaInterpolation / mediaFeature) { return m; })* {
		rest.unshift(first);
		return {
			type: 'mediaQuery',
			children: rest,
			loc: loc()
		};
	}

mediaInterpolation
	= value:variable {
		return {
			type: 'mediaInterpolation',
			children: [value],
			loc: loc()
		};
	}

mediaType
	= modifier:(m:('only'i / 'not'i) _ { return m; })? value:identifier {
		return {
			type: 'mediaType',
			modifier: modifier || '',
			children: [value],
			loc: loc()
		};
	}

mediaFeature
	= '(' _ name:identifier _ value:(':' _ v:list _ { return v; })? ')' {
		return {
			type: 'mediaFeature',
			children: [name, value || null],
			loc: loc()
		};
	}

extend
	= '@extend'i _ selList:selectorList _ semicolon {
		return {
			type: 'extend',
			children: [selList],
			loc: loc()
		};
	}

void
	= '@void'i _ ruleList:ruleList {
		return {
			type: 'void',
			children: [ruleList],
			loc: loc()
		};
	}

block
	= '@block'i _ ruleList:ruleList {
		return {
			type: 'block',
			children: [ruleList],
			loc: loc()
		};
	}

import
	= '@import'i _ url:(string / url / variable) _ mqList:(m:mediaQueryList _ { return m; })? semicolon {
		return {
			type: 'import',
			children: [url, mqList || null],
			loc: loc()
		};
	}

url
	= 'url('i _ value:(string / variable / address) _ ')' {
		return {
			type: 'url',
			children: [value],
			loc: loc()
		};
	}

address
	= value:$([!#$%&*-~]+) {
		return value;
	}

if
	= '@if'i _ condition:list _ consequence:ruleList alternative:(_ e:(elseIf / else) { return e; })? {
		return {
			type: 'if',
			children: [condition, consequence, alternative || null],
			loc: loc()
		};
	}

elseIf
	= '@else'i _ 'if'i _ condition:list _ consequence:ruleList alternative:(_ e:(elseIf / else) { return e; })? {
		return {
			type: 'if',
			children: [condition, consequence, alternative || null],
			loc: loc()
		};
	}

else
	= '@else'i _ ruleList:ruleList {
		return ruleList;
	}

for
	= '@for'i _ variable:variable _ index:(',' _ i:variable _ { return i; })? step:('by'i _ a:additive _ { return a; })? 'in'i _ target:list _ ruleList:ruleList {
		return {
			type: 'for',
			children: [variable, index || null, step || null, target, ruleList],
			loc: loc()
		};
	}

mixin
	= '@mixin'i _ name:variable argList:argumentList _ semicolon {
		return {
			type: 'call',
			mixin: true,
			children: [name, argList],
			loc: loc()
		};
	}

return
	= '@return'i _ list:list _ semicolon {
		return {
			type: 'return',
			children: [list],
			loc: loc()
		};
	}

keyframes
	= '@' prefix:('-' p:$([a-z_]i [a-z0-9_]i*) '-' { return p; })? 'keyframes'i _ name:identifier _ kfList:keyframeList {
		return {
			type: 'keyframes',
			prefix: prefix || '',
			children: [name, kfList],
			loc: loc()
		};
	}

keyframeList
	= '{' kfRules:keyframeRules _ '}' {
		return {
			type: 'ruleList',
			children: kfRules,
			loc: loc()
		};
	}

keyframeRules
	= keyframeRule*

keyframeRule
	= comments:_c kf:keyframe { kf.comments = comments; return kf; }
	/ _ assign:assignment { return assign; }

keyframe
	= selList:keyframeSelectorList _ propList:propertyList {
		return {
			type: 'keyframe',
			children: [selList, propList],
			loc: loc()
		};
	}

keyframeSelectorList
	= first:keyframeSelector rest:(_ ',' _ k:keyframeSelector { return k; })* {
		rest.unshift(first);
		return {
			type: 'keyframeSelectorList',
			children: rest,
			loc: loc()
		};
	}

keyframeSelector
	= value:('from'i / 'to'i / percentage) {
		return {
			type: 'keyframeSelector',
			children: [value],
			loc: loc()
		};
	}

propertyList
	= '{' propRules:propertyRules _ '}' {
		return {
			type: 'ruleList',
			children: propRules,
			loc: loc()
		};
	}

propertyRules
	= propertyRule*

propertyRule
	= comments:_c prop:property { prop.comments = comments; return prop; }
	/ _ assign:assignment { return assign; }
	/ _ stmt:statement { return stmt; }

fontFace
	= '@font-face'i _ propList:propertyList {
		return {
			type: 'fontFace',
			children: [propList],
			loc: loc()
		};
	}

module
	= '@module'i _ name:additive separator:(_ 'with' _ s:list { return s; })? _ ruleList:ruleList {
		return {
			type: 'module',
			children: [name, separator || null, ruleList],
			loc: loc()
		};
	}

page
	= '@page'i name:(_ ':' i:identifier { return i; })? _ propList:propertyList {
		return {
			type: 'page',
			children: [name || null, propList],
			loc: loc()
		};
	}

charset
	= '@charset'i _ value:string _ semicolon {
		return {
			type: 'charset',
			children: [value],
			loc: loc()
		};
	}
_
	= s?

s
	= (ws / singleLineComment / multiLineComment)+

ws
	= $([ \t\r\n\f]+)

singleLineComment
	= $('//' [^\r\n\f]*)

multiLineComment
	= $('/*' ([^*] / '*' [^/])* '*/')

_c
	= comments:(ws:ws {
		var lines = ws.split(/\r\n|[\n\r\f]/);
		var lastLine = lines[lines.length - 1];
		indent = /^\s*/.exec(lastLine)[0];
	} / comment:singleLineComment {
		    return { type: 'singleline', text: comment };
	} / comment:multiLineComment {
		var lines = comment.split(/\r\n|[\n\r\f]/);
		var re = new RegExp('^' +  indent);
		return { type: 'multiline', text: lines.map(function (line) {
			return line.replace(re, '');
		}).join('\n') };
	})* {
		return comments.filter(Boolean);
	}
