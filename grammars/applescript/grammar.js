/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

// AppleScript grammar with block structure support
// AppleScript's English-like syntax is inherently ambiguous for LR parsing,
// so we use error recovery and loose matching for expressions.

// Helper for case-insensitive keywords
const ci = (word) => {
  return new RegExp(
    word
      .split("")
      .map((char) => {
        if (/[a-zA-Z]/.test(char)) {
          return `[${char.toLowerCase()}${char.toUpperCase()}]`;
        }
        return char;
      })
      .join("")
  );
};

module.exports = grammar({
  name: "applescript",

  extras: ($) => [/\s/, $.comment],

  conflicts: ($) => [],

  rules: {
    source_file: ($) => repeat($._item),

    _item: ($) =>
      choice(
        $.handler_definition,
        $.tell_block,
        $.if_block,
        $.repeat_block,
        $.try_block,
        $.property_declaration,
        $.set_statement,
        $.return_statement,
        $._expression
      ),

    // Handler definition: on/to handler_name(params) ... end [handler_name]
    handler_definition: ($) =>
      prec.right(
        seq(
          field("keyword", $.keyword_function),
          field("name", $.identifier),
          optional($.parameter_list),
          repeat($._item),
          $.keyword_end,
          optional($.identifier)
        )
      ),

    keyword_function: ($) => token(choice(ci("on"), ci("to"))),

    keyword_end: ($) => token(ci("end")),

    parameter_list: ($) =>
      prec(
        2,
        seq(
          "(",
          optional(seq($.identifier, repeat(seq(",", $.identifier)))),
          ")"
        )
      ),

    // Tell block: tell target ... end tell
    tell_block: ($) =>
      prec.right(
        seq(
          field("keyword", $.keyword_tell),
          $._expression,
          repeat($._item),
          $.keyword_end,
          optional(token(ci("tell")))
        )
      ),

    keyword_tell: ($) => token(ci("tell")),

    // If block: if condition then ... [else ...] end [if]
    if_block: ($) =>
      prec.right(
        seq(
          field("keyword", $.keyword_if),
          $._expression,
          $.keyword_then,
          repeat($._item),
          optional($.else_clause),
          $.keyword_end,
          optional(token(ci("if")))
        )
      ),

    keyword_if: ($) => token(ci("if")),
    keyword_then: ($) => token(ci("then")),

    else_clause: ($) =>
      seq($.keyword_else, repeat($._item)),

    keyword_else: ($) => token(ci("else")),

    // Repeat block: repeat ... end repeat
    repeat_block: ($) =>
      prec.right(
        seq(
          field("keyword", $.keyword_repeat),
          optional($._repeat_clause),
          repeat($._item),
          $.keyword_end,
          optional(token(ci("repeat")))
        )
      ),

    keyword_repeat: ($) => token(ci("repeat")),

    _repeat_clause: ($) =>
      choice(
        seq(token(ci("with")), $.identifier, token(ci("from")), $._expression, token(ci("to")), $._expression),
        seq(token(ci("with")), $.identifier, token(ci("in")), $._expression),
        seq(token(ci("while")), $._expression),
        seq(token(ci("until")), $._expression),
        seq($._expression, token(ci("times")))
      ),

    // Try block: try ... on error ... end try
    try_block: ($) =>
      prec.right(
        seq(
          field("keyword", $.keyword_try),
          repeat($._item),
          optional($.error_handler),
          $.keyword_end,
          optional(token(ci("try")))
        )
      ),

    keyword_try: ($) => token(ci("try")),

    error_handler: ($) =>
      prec.right(
        1,
        seq(
          $.keyword_on_error,
          optional($.identifier),
          repeat($._item)
        )
      ),

    keyword_on_error: ($) => token(seq(ci("on"), /\s+/, ci("error"))),

    // Property declaration
    property_declaration: ($) =>
      seq(
        $.keyword_property,
        field("name", $.identifier),
        ":",
        $._expression
      ),

    keyword_property: ($) => token(ci("property")),

    // Set statement
    set_statement: ($) =>
      seq(
        $.keyword_set,
        field("variable", $.identifier),
        token(ci("to")),
        $._expression
      ),

    keyword_set: ($) => token(ci("set")),

    // Return statement
    return_statement: ($) =>
      prec.right(
        seq(
          $.keyword_return,
          optional($._expression)
        )
      ),

    keyword_return: ($) => token(ci("return")),

    // Expressions - simplified to avoid ambiguity
    _expression: ($) =>
      choice(
        $.string,
        $.number,
        $.boolean,
        $.list,
        $.record,
        $.parenthesized_expression,
        $.reference,
        $.operator,
        $.identifier
      ),

    parenthesized_expression: ($) => seq("(", repeat($._expression), ")"),

    list: ($) => seq("{", repeat(choice($._expression, ",")), "}"),

    record: ($) => seq("{", $.record_entry, repeat(seq(",", $.record_entry)), "}"),

    record_entry: ($) => seq($.identifier, ":", $._expression),

    reference: ($) =>
      seq(
        $.keyword_application,
        $.string
      ),

    keyword_application: ($) => token(ci("application")),

    // Literals
    string: ($) => /"[^"]*"/,

    number: ($) => /\d+(\.\d+)?/,

    boolean: ($) => token(choice(ci("true"), ci("false"))),

    // Operators
    operator: ($) =>
      token(
        choice(
          "=",
          "≠",
          "/=",
          "<",
          ">",
          "≤",
          "<=",
          "≥",
          ">=",
          "+",
          "-",
          "*",
          "/",
          "^",
          "&",
          "¬",
          ci("and"),
          ci("or"),
          ci("not"),
          ci("is"),
          ci("of"),
          ci("contains"),
          ci("mod"),
          ci("div")
        )
      ),

    identifier: ($) => /[a-zA-Z_][a-zA-Z0-9_]*/,

    comment: ($) =>
      token(
        choice(
          seq("--", /.*/),
          seq("(*", /[^*]*\*+([^)*][^*]*\*+)*/, ")"),
          seq("#!", /.*/)
        )
      ),
  },
});
