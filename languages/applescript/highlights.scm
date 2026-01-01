; Comments
(comment) @comment

; Strings and escape sequences
(string) @string
(escape_sequence) @string.escape

; Numbers
(number) @number

; Booleans and special values
(boolean) @boolean
(missing_value) @constant.builtin
(null_value) @constant.builtin
(current_application) @constant.builtin
(me_reference) @variable.special
(it_reference) @variable.special
(result_reference) @variable.special

; Operators
(comparison_operator) @operator
(logical_operator) @operator
(additive_operator) @operator
(multiplicative_operator) @operator
(unary_operator) @operator
(range_operator) @operator

; Type specifiers for coercion
(type_specifier) @type

; Element types for object specifiers
(element_type) @type
(specifier_prefix) @keyword

; Command names (display dialog, do shell script, etc.)
(command_name) @function.builtin

; Parameter names in command calls
(parameter_name) @property

; Function/handler keywords (on, to)
(keyword_function) @keyword.function
(keyword_on) @keyword.function
(keyword_handler_to) @keyword.function
(keyword_to) @keyword

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
(keyword_using_terms_from) @keyword.control

; Script keyword
(keyword_script) @keyword

; Statement keywords
(keyword_set) @keyword
(keyword_copy) @keyword
(keyword_return) @keyword.return
(keyword_error) @keyword
(keyword_log) @keyword
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

; Given clause labeled parameters
(labeled_parameter
  label: (identifier) @property
  name: (identifier) @variable.parameter)

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

; Tell block target
(tell_block
  target: (identifier) @variable)
(tell_simple_statement
  target: (identifier) @variable)

; Property references
(property_reference
  (identifier) @property)

; General identifiers (fallback)
(identifier) @variable
