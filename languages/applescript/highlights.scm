; Comments
(comment) @comment

; Strings
(string) @string

; Numbers
(number) @number

; Booleans
(boolean) @constant.builtin

; Operators
(operator) @operator

; Function/handler keywords (on, to)
(keyword_function) @keyword.function

; Control flow keywords
(keyword_if) @keyword.control
(keyword_then) @keyword.control
(keyword_else) @keyword.control
(keyword_tell) @keyword.control
(keyword_repeat) @keyword.control
(keyword_try) @keyword.control
(keyword_end) @keyword.control
(keyword_on_error) @keyword.control

; Statement keywords
(keyword_set) @keyword
(keyword_return) @keyword.return
(keyword_property) @keyword
(keyword_application) @keyword

; Handler names
(handler_definition
  name: (identifier) @function)

; Parameter names
(parameter_list
  (identifier) @variable.parameter)

; Variable in set statement
(set_statement
  variable: (identifier) @variable)

; Property declaration name
(property_declaration
  name: (identifier) @property)

; General identifiers
(identifier) @variable
