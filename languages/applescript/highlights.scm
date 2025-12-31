; Keywords
[
  "on"
  "to"
  "end"
  "tell"
  "if"
  "then"
  "else"
  "repeat"
  "while"
  "until"
  "from"
  "by"
  "times"
  "try"
  "error"
  "with"
  "timeout"
  "transaction"
  "considering"
  "ignoring"
  "but"
  "using"
  "terms"
  "use"
  "set"
  "local"
  "global"
  "property"
  "return"
  "exit"
  "of"
  "in"
  "is"
  "not"
  "and"
  "or"
  "a"
  "an"
  "the"
  "my"
  "me"
  "it"
  "result"
  "application"
  "script"
  "framework"
  "version"
] @keyword

; Control flow keywords
[
  "if"
  "then"
  "else"
  "repeat"
  "while"
  "until"
  "exit"
] @keyword.control

; Exception keywords
[
  "try"
  "error"
  "on error"
] @keyword.exception

; Storage/declaration keywords
[
  "set"
  "local"
  "global"
  "property"
] @keyword.storage

; Function definition
(handler_definition
  name: (identifier) @function.definition)

; Tell block target
(tell_block
  target: (application_expression) @type)

(tell_block
  target: (identifier) @type)

; Application expression
(application_expression) @type

; Parameter definitions
(parameter) @variable.parameter

; Comments
(comment) @comment

; Strings
(string) @string
(escape_sequence) @string.escape

; Numbers
(number) @number

; Booleans
(boolean) @boolean

; Special values
(missing_value) @constant.builtin
(it_expression) @variable.builtin
(me_expression) @variable.builtin
(result_expression) @variable.builtin

; Operators
[
  "="
  "≠"
  "/="
  "<"
  ">"
  "≤"
  "<="
  "≥"
  ">="
  "+"
  "-"
  "*"
  "/"
  "^"
  "&"
  ":"
  ","
] @operator

; Comparison keywords as operators
[
  "is"
  "equals"
  "is not"
  "isn't"
  "is less than"
  "comes before"
  "is greater than"
  "comes after"
  "is less than or equal to"
  "is less than or equal"
  "is greater than or equal to"
  "is greater than or equal"
  "contains"
  "is in"
  "is contained by"
  "starts with"
  "ends with"
  "div"
  "mod"
] @keyword.operator

; Identifiers
(identifier) @variable

; Record fields
(record_field
  key: (identifier) @property)

; Command statements (first identifier is the command name)
(command_statement
  . (identifier) @function.call)

; Labeled arguments
(labeled_argument
  . (identifier) @property)

; Consideration attributes
(consideration_attribute) @constant

; Punctuation
[
  "("
  ")"
  "{"
  "}"
] @punctuation.bracket

[
  ","
  ":"
] @punctuation.delimiter

; Use statement components
(use_statement
  "scripting additions" @type)
