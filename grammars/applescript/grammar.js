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
        $.script_block,
        $.tell_block,
        $.if_block,
        $.repeat_block,
        $.try_block,
        $.considering_block,
        $.ignoring_block,
        $.timeout_block,
        $.use_statement,
        $.property_declaration,
        $.global_declaration,
        $.local_declaration,
        $.set_statement,
        $.copy_statement,
        $.return_statement,
        $.exit_statement,
        $.continue_statement,
        $._expression
      ),

    // ==================== HANDLERS ====================

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

    // ==================== SCRIPT OBJECTS ====================

    // Script block: script [name] ... end script
    script_block: ($) =>
      prec.right(
        1,
        seq(
          field("keyword", $.keyword_script),
          optional(field("name", $.identifier)),
          repeat($._item),
          $.keyword_end,
          optional(token(ci("script")))
        )
      ),

    keyword_script: ($) => token(ci("script")),

    // ==================== TELL BLOCK ====================

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

    // ==================== IF BLOCK ====================

    // If block: if condition then ... [else if ... then ...] [else ...] end [if]
    if_block: ($) =>
      prec.right(
        seq(
          field("keyword", $.keyword_if),
          field("condition", $._expression),
          $.keyword_then,
          repeat($._item),
          repeat($.else_if_clause),
          optional($.else_clause),
          $.keyword_end,
          optional(token(ci("if")))
        )
      ),

    keyword_if: ($) => token(ci("if")),
    keyword_then: ($) => token(ci("then")),

    else_if_clause: ($) =>
      seq(
        $.keyword_else_if,
        field("condition", $._expression),
        $.keyword_then,
        repeat($._item)
      ),

    keyword_else_if: ($) => token(seq(ci("else"), /\s+/, ci("if"))),

    else_clause: ($) => seq($.keyword_else, repeat($._item)),

    keyword_else: ($) => token(ci("else")),

    // ==================== REPEAT BLOCK ====================

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
        seq(
          token(ci("with")),
          $.identifier,
          token(ci("from")),
          $._expression,
          token(ci("to")),
          $._expression,
          optional(seq(token(ci("by")), $._expression))
        ),
        seq(token(ci("with")), $.identifier, token(ci("in")), $._expression),
        seq(token(ci("while")), $._expression),
        seq(token(ci("until")), $._expression),
        seq($._expression, token(ci("times")))
      ),

    // ==================== TRY BLOCK ====================

    // Try block: try ... on error [errMsg] [number errNum] ... end try
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
          optional($.error_parameters),
          repeat($._item)
        )
      ),

    error_parameters: ($) =>
      prec(
        2,
        choice(
          seq($.identifier, optional(seq(token(ci("number")), $.identifier))),
          seq(token(ci("number")), $.identifier)
        )
      ),

    keyword_on_error: ($) => token(seq(ci("on"), /\s+/, ci("error"))),

    // ==================== CONSIDERING/IGNORING BLOCKS ====================

    // Considering block: considering attribute [, attribute]... ... end considering
    considering_block: ($) =>
      prec.right(
        seq(
          field("keyword", $.keyword_considering),
          $.text_attribute,
          repeat(seq(",", $.text_attribute)),
          repeat($._item),
          $.keyword_end,
          optional(token(ci("considering")))
        )
      ),

    keyword_considering: ($) => token(ci("considering")),

    // Ignoring block: ignoring attribute [, attribute]... ... end ignoring
    ignoring_block: ($) =>
      prec.right(
        seq(
          field("keyword", $.keyword_ignoring),
          $.text_attribute,
          repeat(seq(",", $.text_attribute)),
          repeat($._item),
          $.keyword_end,
          optional(token(ci("ignoring")))
        )
      ),

    keyword_ignoring: ($) => token(ci("ignoring")),

    text_attribute: ($) =>
      token(
        choice(
          ci("case"),
          ci("diacriticals"),
          ci("hyphens"),
          ci("punctuation"),
          ci("white space"),
          seq(ci("application"), /\s+/, ci("responses"))
        )
      ),

    // ==================== TIMEOUT BLOCK ====================

    // With timeout block: with timeout [of] N seconds ... end timeout
    timeout_block: ($) =>
      prec.right(
        seq(
          field("keyword", $.keyword_with_timeout),
          optional(token(ci("of"))),
          $._expression,
          token(ci("seconds")),
          repeat($._item),
          $.keyword_end,
          optional(token(ci("timeout")))
        )
      ),

    keyword_with_timeout: ($) => token(seq(ci("with"), /\s+/, ci("timeout"))),

    // ==================== USE STATEMENTS ====================

    // Use statement: use framework "X" / use scripting additions / use application "X"
    use_statement: ($) =>
      seq(
        $.keyword_use,
        choice(
          seq(token(ci("AppleScript")), optional(seq(token(ci("version")), $.string))),
          seq(token(ci("framework")), $.string),
          seq(token(ci("scripting")), token(ci("additions"))),
          seq(token(ci("application")), $.string)
        )
      ),

    keyword_use: ($) => token(ci("use")),

    // ==================== DECLARATIONS ====================

    // Property declaration
    property_declaration: ($) =>
      seq(
        $.keyword_property,
        field("name", $.identifier),
        ":",
        field("value", $._expression)
      ),

    keyword_property: ($) => token(ci("property")),

    // Global declaration
    global_declaration: ($) =>
      seq(
        $.keyword_global,
        $.identifier,
        repeat(seq(",", $.identifier))
      ),

    keyword_global: ($) => token(ci("global")),

    // Local declaration
    local_declaration: ($) =>
      seq(
        $.keyword_local,
        $.identifier,
        repeat(seq(",", $.identifier))
      ),

    keyword_local: ($) => token(ci("local")),

    // ==================== STATEMENTS ====================

    // Set statement
    set_statement: ($) =>
      seq(
        $.keyword_set,
        field("variable", $._expression),
        token(ci("to")),
        field("value", $._expression)
      ),

    keyword_set: ($) => token(ci("set")),

    // Copy statement
    copy_statement: ($) =>
      seq(
        $.keyword_copy,
        field("value", $._expression),
        token(ci("to")),
        field("variable", $._expression)
      ),

    keyword_copy: ($) => token(ci("copy")),

    // Return statement
    return_statement: ($) =>
      prec.right(
        seq(
          $.keyword_return,
          optional($._expression)
        )
      ),

    keyword_return: ($) => token(ci("return")),

    // Exit statement
    exit_statement: ($) =>
      prec.right(
        seq(
          $.keyword_exit,
          optional(token(ci("repeat")))
        )
      ),

    keyword_exit: ($) => token(ci("exit")),

    // Continue statement
    continue_statement: ($) => $.keyword_continue,

    keyword_continue: ($) => token(ci("continue")),

    // ==================== EXPRESSIONS ====================

    // Expressions - simplified to avoid ambiguity
    _expression: ($) =>
      choice(
        $.string,
        $.number,
        $.boolean,
        $.missing_value,
        $.list,
        $.record,
        $.parenthesized_expression,
        $.reference,
        $.operator,
        $.identifier
      ),

    parenthesized_expression: ($) => seq("(", repeat($._expression), ")"),

    list: ($) => seq("{", optional(seq($._expression, repeat(seq(",", $._expression)))), "}"),

    record: ($) => seq("{", $.record_entry, repeat(seq(",", $.record_entry)), "}"),

    record_entry: ($) => seq($.identifier, ":", $._expression),

    reference: ($) =>
      seq(
        $.keyword_application,
        $.string
      ),

    keyword_application: ($) => token(ci("application")),

    // ==================== LITERALS ====================

    // String with escape sequences
    string: ($) =>
      seq(
        '"',
        repeat(
          choice(
            $.escape_sequence,
            /[^"\\]+/
          )
        ),
        '"'
      ),

    escape_sequence: ($) =>
      token.immediate(
        choice(
          "\\\\",
          '\\"',
          "\\n",
          "\\r",
          "\\t"
        )
      ),

    number: ($) => /\d+(\.\d+)?/,

    boolean: ($) => token(choice(ci("true"), ci("false"))),

    missing_value: ($) => token(seq(ci("missing"), /\s+/, ci("value"))),

    // ==================== OPERATORS ====================

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
          ci("as"),
          ci("a"),
          ci("an"),
          ci("the"),
          ci("some"),
          ci("every"),
          ci("contains"),
          ci("starts with"),
          ci("ends with"),
          ci("is in"),
          ci("is not in"),
          ci("mod"),
          ci("div"),
          ci("ref"),
          ci("reference")
        )
      ),

    // ==================== IDENTIFIERS & COMMENTS ====================

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
