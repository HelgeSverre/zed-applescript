### Define a word token in a grammar

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/creating-parsers/3-writing-the-grammar.md

Specify an identifier rule as the word token to enable automatic keyword extraction for tokens that match the word pattern.

```js
grammar({
  name: "javascript",

  word: $ => $.identifier,

  rules: {
    expression: $ =>
      choice(
        $.identifier,
        $.unary_expression,
        $.binary_expression,
        // ...
      ),

    binary_expression: $ =>
      choice(
        prec.left(1, seq($.expression, "instanceof", $.expression)),
        // ...
      ),

    unary_expression: $ =>
      choice(
        prec.left(2, seq("typeof", $.expression)),
        // ...
      ),

    identifier: $ => /[a-z_]+/,
  },
});
```

--------------------------------

### Tree-sitter Grammar DSL Example

Source: https://context7.com/tree-sitter/tree-sitter/llms.txt

Defines a simple arithmetic grammar using the Tree-sitter DSL, including tokens, precedences, and rules for expressions, assignments, and identifiers.

```javascript
/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

export default grammar({
  name: 'arithmetic',

  // Tokens that may appear anywhere (whitespace)
  extras: $ => [/\s/],

  // Named precedence levels (descending order)
  precedences: $ => [
    ['multiply', 'add'],
  ],

  rules: {
    source_file: $ => repeat($._statement),

    _statement: $ => choice(
      $.expression_statement,
      $.assignment,
    ),

    expression_statement: $ => seq($._expr, ';'),

    assignment: $ => seq(
      field('left',  $.identifier),
      '=',
      field('right', $._expr),
      ';',
    ),

    _expr: $ => choice(
      $.binary_expr,
      $.number,
      $.identifier,
      seq('(', $._expr, ')'),
    ),

    // Associativity and precedence
    binary_expr: $ => choice(
      prec.left('multiply', seq($._expr, field('operator', choice('*', '/')), $._expr)),
      prec.left('add',      seq($._expr, field('operator', choice('+', '-')), $._expr)),
    ),

    number: $ => /[0-9]+(\.[0-9]+)?/,

    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,
  },
});
```

--------------------------------

### Preferable Way to Define Extras

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/creating-parsers/3-writing-the-grammar.md

Define complex tokens like comments as separate rules and then reference them in the `extras` function. This avoids lexer inlining and reduces parser size.

```javascript
module.exports = grammar({
  name: "my_language",

  extras: ($) => [
    /\s/, // whitespace
    $.comment,
  ],

  rules: {
    // ...

    comment: ($) =>
      token(
        choice(seq("//", /.*/), seq("/*", /[^*]*\*+([^/*][^*]*\*+)*/, "/")),
      ),
  },
});
```

--------------------------------

### Defining Intended LR(1) Conflicts

Source: https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/creating-parsers/2-the-grammar-dsl.md

The `conflicts` field is an array of rule name arrays, defining sets of rules involved in intended LR(1) conflicts. Tree-sitter uses the GLR algorithm to resolve these, prioritizing rules with higher dynamic precedence.

```javascript
conflicts: [[$.rule1, $.rule2]]
```

### Grammar DSL (grammar.js) > Writing a grammar with the built-in DSL functions

Source: https://context7.com/tree-sitter/tree-sitter/llms.txt

When writing a grammar using the built-in DSL functions, rules are defined as JavaScript functions receiving `$`. The DSL provides functions for sequencing (`seq`), choice (`choice`), repetition (`repeat`, `repeat1`), optional elements (`optional`), precedence (`prec`, `prec.left`, `prec.right`), tokens (`token`), aliasing (`alias`), and fields (`field`).
