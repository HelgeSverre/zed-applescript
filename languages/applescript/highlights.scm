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
(applescript_constant) @constant.builtin
(me_reference) @variable.special
(it_reference) @variable.special
(its_reference) @variable.special
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
(keyword_with_transaction) @keyword.control
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

; Tell block target — `tell foo` (identifier) or `tell application "X"` (reference)
(tell_block
  target: (identifier) @variable)
; tell_simple_statement target is always a `reference (keyword_application string)`,
; which is already highlighted via the @keyword / @string rules above.

; Property references — highlight the leading name part(s)
(property_reference
  (compound_name) @property)

; Possessive accessor: x's y — highlight the trailing name as a property
(possessive_expression
  (possessive) @punctuation.delimiter
  (compound_name) @property)

; ObjC bridge method call: receiver's selector:arg [label:arg ...]
(objc_selector_call
  (possessive) @punctuation.delimiter
  (identifier) @function.method)

; Direct handler call: `userPicksFolder()`, `f(x, y, z)`
(handler_call
  (identifier) @function)

; Raw data literal: «class fold», «data utxt201C»
(raw_data) @constant.builtin

; my <expr> — script self-reference
(keyword_my) @keyword

; ObjC-style handler definition: highlight selector words as function name
(objc_handler_definition
  (identifier) @function)

; Folder Action multi-word event names
(folder_action_event) @function

; current_date and the_keyword
(current_date) @constant.builtin
(the_keyword) @keyword

; implicit `end run` at top level
(implicit_run_end) @keyword.control

; `a reference to <expr>` keyword prefix is a single multi-word token; highlight
; the wrapped expression node itself.
(reference_to_expression) @variable.special

; Date literal: `date "..."`
(date_literal) @constant.builtin

; `new <element_type>` used as the argument to `make`
(new_specifier
  (element_type) @type)

; `whose`/`where` filter clause on object specifiers — the keyword is a hidden
; token inside whose_clause; highlight the rule as control-flow.
(whose_clause) @keyword.control

; General identifiers (fallback)
(identifier) @variable
