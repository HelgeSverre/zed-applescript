/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "applescript",

  extras: ($) => [/\s/, $.comment],

  word: ($) => $.identifier,

  rules: {
    source_file: ($) => repeat($._statement),

    _statement: ($) =>
      choice(
        $.use_statement,
        $.property_declaration,
        $.variable_declaration,
        $.handler_definition,
        $.tell_block,
        $.if_statement,
        $.repeat_statement,
        $.try_statement,
        $.with_timeout_block,
        $.with_transaction_block,
        $.considering_block,
        $.ignoring_block,
        $.using_terms_block,
        $.command_statement,
        $.assignment_statement,
        $.return_statement,
        $.error_statement,
        $.exit_statement,
        $._expression
      ),

    // Use statements (AppleScript 2.3+)
    use_statement: ($) =>
      seq(
        caseInsensitive("use"),
        choice(
          seq(caseInsensitive("application"), $.string),
          seq(caseInsensitive("framework"), $.string),
          seq(caseInsensitive("script"), $.string),
          seq(caseInsensitive("scripting additions"))
        ),
        optional(seq(caseInsensitive("version"), $.string))
      ),

    // Property declaration
    property_declaration: ($) =>
      seq(
        caseInsensitive("property"),
        field("name", $.identifier),
        ":",
        field("value", $._expression)
      ),

    // Variable declaration
    variable_declaration: ($) =>
      seq(
        choice(
          caseInsensitive("set"),
          caseInsensitive("local"),
          caseInsensitive("global")
        ),
        field("name", $.identifier),
        caseInsensitive("to"),
        field("value", $._expression)
      ),

    // Assignment statement
    assignment_statement: ($) =>
      seq(
        caseInsensitive("set"),
        field("target", $._expression),
        caseInsensitive("to"),
        field("value", $._expression)
      ),

    // Handler definitions
    handler_definition: ($) =>
      seq(
        choice(caseInsensitive("on"), caseInsensitive("to")),
        field("name", $.identifier),
        optional($.parameter_list),
        repeat($._statement),
        caseInsensitive("end"),
        optional($.identifier)
      ),

    parameter_list: ($) =>
      seq("(", optional(seq($.parameter, repeat(seq(",", $.parameter)))), ")"),

    parameter: ($) => $.identifier,

    // Tell block
    tell_block: ($) =>
      choice(
        // Multi-line tell block
        seq(
          caseInsensitive("tell"),
          field("target", $._expression),
          repeat($._statement),
          caseInsensitive("end"),
          optional(caseInsensitive("tell"))
        ),
        // Single-line tell
        seq(
          caseInsensitive("tell"),
          field("target", $._expression),
          caseInsensitive("to"),
          $._statement
        )
      ),

    // If statement
    if_statement: ($) =>
      choice(
        // Multi-line if
        seq(
          caseInsensitive("if"),
          field("condition", $._expression),
          caseInsensitive("then"),
          repeat($._statement),
          repeat($.else_if_clause),
          optional($.else_clause),
          caseInsensitive("end"),
          optional(caseInsensitive("if"))
        ),
        // Single-line if
        seq(
          caseInsensitive("if"),
          field("condition", $._expression),
          caseInsensitive("then"),
          $._statement
        )
      ),

    else_if_clause: ($) =>
      seq(
        caseInsensitive("else"),
        caseInsensitive("if"),
        field("condition", $._expression),
        caseInsensitive("then"),
        repeat($._statement)
      ),

    else_clause: ($) => seq(caseInsensitive("else"), repeat($._statement)),

    // Repeat statement
    repeat_statement: ($) =>
      seq(
        caseInsensitive("repeat"),
        optional(
          choice(
            seq($._expression, caseInsensitive("times")),
            seq(caseInsensitive("until"), $._expression),
            seq(caseInsensitive("while"), $._expression),
            seq(
              caseInsensitive("with"),
              $.identifier,
              choice(
                seq(
                  caseInsensitive("from"),
                  $._expression,
                  caseInsensitive("to"),
                  $._expression,
                  optional(seq(caseInsensitive("by"), $._expression))
                ),
                seq(caseInsensitive("in"), $._expression)
              )
            )
          )
        ),
        repeat($._statement),
        caseInsensitive("end"),
        optional(caseInsensitive("repeat"))
      ),

    // Try statement
    try_statement: ($) =>
      seq(
        caseInsensitive("try"),
        repeat($._statement),
        optional($.on_error_clause),
        caseInsensitive("end"),
        optional(caseInsensitive("try"))
      ),

    on_error_clause: ($) =>
      seq(
        caseInsensitive("on"),
        caseInsensitive("error"),
        optional($.identifier),
        optional(seq(caseInsensitive("number"), $.identifier)),
        optional(seq(caseInsensitive("from"), $.identifier)),
        optional(seq(caseInsensitive("to"), $.identifier)),
        optional(seq(caseInsensitive("partial"), caseInsensitive("result"), $.identifier)),
        repeat($._statement)
      ),

    // With timeout block
    with_timeout_block: ($) =>
      seq(
        caseInsensitive("with"),
        caseInsensitive("timeout"),
        optional(seq(caseInsensitive("of"), $._expression, caseInsensitive("seconds"))),
        repeat($._statement),
        caseInsensitive("end"),
        optional(caseInsensitive("timeout"))
      ),

    // With transaction block
    with_transaction_block: ($) =>
      seq(
        caseInsensitive("with"),
        caseInsensitive("transaction"),
        optional($._expression),
        repeat($._statement),
        caseInsensitive("end"),
        optional(caseInsensitive("transaction"))
      ),

    // Considering block
    considering_block: ($) =>
      seq(
        caseInsensitive("considering"),
        $.consideration_attribute,
        repeat(seq(choice(",", caseInsensitive("and")), $.consideration_attribute)),
        optional(
          seq(
            caseInsensitive("but"),
            choice(caseInsensitive("ignoring"), caseInsensitive("considering")),
            $.consideration_attribute,
            repeat(seq(choice(",", caseInsensitive("and")), $.consideration_attribute))
          )
        ),
        repeat($._statement),
        caseInsensitive("end"),
        optional(caseInsensitive("considering"))
      ),

    // Ignoring block
    ignoring_block: ($) =>
      seq(
        caseInsensitive("ignoring"),
        $.consideration_attribute,
        repeat(seq(choice(",", caseInsensitive("and")), $.consideration_attribute)),
        optional(
          seq(
            caseInsensitive("but"),
            choice(caseInsensitive("ignoring"), caseInsensitive("considering")),
            $.consideration_attribute,
            repeat(seq(choice(",", caseInsensitive("and")), $.consideration_attribute))
          )
        ),
        repeat($._statement),
        caseInsensitive("end"),
        optional(caseInsensitive("ignoring"))
      ),

    consideration_attribute: ($) =>
      choice(
        caseInsensitive("case"),
        caseInsensitive("diacriticals"),
        caseInsensitive("hyphens"),
        caseInsensitive("punctuation"),
        caseInsensitive("white space"),
        seq(caseInsensitive("application"), caseInsensitive("responses"))
      ),

    // Using terms from block
    using_terms_block: ($) =>
      seq(
        caseInsensitive("using"),
        caseInsensitive("terms"),
        caseInsensitive("from"),
        choice(
          seq(caseInsensitive("application"), $.string),
          seq(caseInsensitive("script"), $.string)
        ),
        repeat($._statement),
        caseInsensitive("end"),
        optional(caseInsensitive("using")),
        optional(caseInsensitive("terms")),
        optional(caseInsensitive("from"))
      ),

    // Command statement
    command_statement: ($) =>
      prec.left(
        seq(
          $.identifier,
          optional($._expression),
          repeat($.labeled_argument)
        )
      ),

    labeled_argument: ($) =>
      seq($.identifier, $._expression),

    // Return statement
    return_statement: ($) =>
      seq(caseInsensitive("return"), optional($._expression)),

    // Error statement
    error_statement: ($) =>
      seq(
        caseInsensitive("error"),
        optional($._expression),
        optional(seq(caseInsensitive("number"), $._expression)),
        optional(seq(caseInsensitive("from"), $._expression)),
        optional(seq(caseInsensitive("to"), $._expression)),
        optional(seq(caseInsensitive("partial"), caseInsensitive("result"), $._expression))
      ),

    // Exit statement
    exit_statement: ($) =>
      seq(caseInsensitive("exit"), optional(caseInsensitive("repeat"))),

    // Expressions
    _expression: ($) =>
      choice(
        $.binary_expression,
        $.unary_expression,
        $.parenthesized_expression,
        $.reference_expression,
        $.application_expression,
        $.list_expression,
        $.record_expression,
        $.string,
        $.number,
        $.boolean,
        $.identifier,
        $.it_expression,
        $.me_expression,
        $.result_expression,
        $.missing_value
      ),

    binary_expression: ($) =>
      choice(
        // Comparison operators
        prec.left(1, seq($._expression, choice("=", "is", "equals"), $._expression)),
        prec.left(1, seq($._expression, choice("≠", "/=", "is not", "isn't"), $._expression)),
        prec.left(2, seq($._expression, choice("<", "is less than", "comes before"), $._expression)),
        prec.left(2, seq($._expression, choice(">", "is greater than", "comes after"), $._expression)),
        prec.left(2, seq($._expression, choice("≤", "<=", "is less than or equal to", "is less than or equal"), $._expression)),
        prec.left(2, seq($._expression, choice("≥", ">=", "is greater than or equal to", "is greater than or equal"), $._expression)),
        // Logical operators
        prec.left(0, seq($._expression, choice(caseInsensitive("and"), "&"), $._expression)),
        prec.left(0, seq($._expression, caseInsensitive("or"), $._expression)),
        // Arithmetic operators
        prec.left(3, seq($._expression, choice("+", "-"), $._expression)),
        prec.left(4, seq($._expression, choice("*", "/", caseInsensitive("div"), caseInsensitive("mod")), $._expression)),
        prec.right(5, seq($._expression, "^", $._expression)),
        // String concatenation
        prec.left(3, seq($._expression, "&", $._expression)),
        // Containment
        prec.left(1, seq($._expression, choice(caseInsensitive("contains"), caseInsensitive("is in"), caseInsensitive("is contained by")), $._expression)),
        prec.left(1, seq($._expression, caseInsensitive("starts with"), $._expression)),
        prec.left(1, seq($._expression, caseInsensitive("ends with"), $._expression))
      ),

    unary_expression: ($) =>
      prec.right(
        6,
        seq(choice("-", caseInsensitive("not")), $._expression)
      ),

    parenthesized_expression: ($) => seq("(", $._expression, ")"),

    // Reference expressions (property access, element access)
    reference_expression: ($) =>
      prec.left(
        7,
        choice(
          seq($._expression, caseInsensitive("of"), $._expression),
          seq($._expression, "'s", $._expression),
          seq($.identifier, $._expression, caseInsensitive("of"), $._expression)
        )
      ),

    // Application reference
    application_expression: ($) =>
      seq(caseInsensitive("application"), $.string),

    // List
    list_expression: ($) =>
      seq("{", optional(seq($._expression, repeat(seq(",", $._expression)))), "}"),

    // Record
    record_expression: ($) =>
      seq(
        "{",
        $.record_field,
        repeat(seq(",", $.record_field)),
        "}"
      ),

    record_field: ($) =>
      seq(field("key", $.identifier), ":", field("value", $._expression)),

    // Special keywords
    it_expression: ($) => caseInsensitive("it"),
    me_expression: ($) => caseInsensitive("me"),
    result_expression: ($) => caseInsensitive("result"),
    missing_value: ($) => caseInsensitive("missing value"),

    // Literals
    string: ($) =>
      choice(
        seq('"', repeat(choice(/[^"\\]/, $.escape_sequence)), '"'),
        seq("«", /[^»]*/, "»")
      ),

    escape_sequence: ($) => token(seq("\\", choice('"', "\\", "n", "r", "t"))),

    number: ($) =>
      token(
        choice(
          /\d+/, // Integer
          /\d+\.\d+/, // Decimal
          /\d+[eE][+-]?\d+/, // Scientific notation
          /\d+\.\d+[eE][+-]?\d+/ // Decimal with scientific notation
        )
      ),

    boolean: ($) => choice(caseInsensitive("true"), caseInsensitive("false")),

    identifier: ($) => /[a-zA-Z_][a-zA-Z0-9_]*/,

    comment: ($) =>
      choice(
        // Line comment
        seq("--", /.*/),
        // Block comment
        seq("(*", /[^*]*\*+([^)*][^*]*\*+)*/, ")"),
        // Hash comment (shebang)
        seq("#", /.*/)
      ),
  },
});

// Helper function for case-insensitive keywords
function caseInsensitive(keyword) {
  return new RegExp(
    keyword
      .split("")
      .map((char) => {
        if (/[a-zA-Z]/.test(char)) {
          return `[${char.toLowerCase()}${char.toUpperCase()}]`;
        }
        return char.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      })
      .join("")
  );
}
