; Comments
(comment) @comment

; Strings and escape sequences
(string) @string
(escape_sequence) @string.escape

; Numbers
(number) @number

; Booleans and special values
(boolean) @constant.builtin
(missing_value) @constant.builtin

; Operators
(operator) @operator

; Function/handler keywords (on, to)
(keyword_function) @keyword.function

; Control flow keywords
(keyword_if) @keyword.control
(keyword_then) @keyword.control
(keyword_else) @keyword.control
(keyword_else_if) @keyword.control
(keyword_tell) @keyword.control
(keyword_repeat) @keyword.control
(keyword_try) @keyword.control
(keyword_end) @keyword.control
(keyword_on_error) @keyword.control
(keyword_exit) @keyword.control
(keyword_continue) @keyword.control
(keyword_considering) @keyword.control
(keyword_ignoring) @keyword.control
(keyword_with_timeout) @keyword.control

; Script keyword
(keyword_script) @keyword

; Statement keywords
(keyword_set) @keyword
(keyword_copy) @keyword
(keyword_return) @keyword.return
(keyword_property) @keyword
(keyword_global) @keyword
(keyword_local) @keyword
(keyword_use) @keyword
(keyword_application) @keyword

; Text attributes (case, diacriticals, etc.)
(text_attribute) @constant

; Handler/function names
(handler_definition
  name: (identifier) @function)

; Script names
(script_block
  name: (identifier) @type)

; Parameter names
(parameter_list
  (identifier) @variable.parameter)

; Variable in set/copy statement
(set_statement
  variable: (identifier) @variable)
(copy_statement
  variable: (identifier) @variable)

; Property declaration name
(property_declaration
  name: (identifier) @property)

; Global/local variable names
(global_declaration
  (identifier) @variable)
(local_declaration
  (identifier) @variable)

; Error handler parameters
(error_parameters
  (identifier) @variable.parameter)

; General identifiers
(identifier) @variable
