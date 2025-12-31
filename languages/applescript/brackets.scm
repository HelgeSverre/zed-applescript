; Bracket pairs for matching
; Uses the parentheses in parameter lists and expressions

(parameter_list
  "(" @open
  ")" @close)

(parenthesized_expression
  "(" @open
  ")" @close)

(list
  "{" @open
  "}" @close)

(record
  "{" @open
  "}" @close)
