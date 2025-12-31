; Parentheses
("(" @open)
(")" @close)

; Braces (lists and records)
("{" @open)
("}" @close)

; Block delimiters using keywords
; Handler blocks
(handler_definition
  ["on" "to"] @open
  "end" @close)

; Tell blocks
(tell_block
  "tell" @open
  "end" @close)

; If statements
(if_statement
  "if" @open
  "end" @close)

; Repeat statements
(repeat_statement
  "repeat" @open
  "end" @close)

; Try statements
(try_statement
  "try" @open
  "end" @close)

; With timeout blocks
(with_timeout_block
  "with" @open
  "end" @close)

; With transaction blocks
(with_transaction_block
  "with" @open
  "end" @close)

; Considering blocks
(considering_block
  "considering" @open
  "end" @close)

; Ignoring blocks
(ignoring_block
  "ignoring" @open
  "end" @close)

; Using terms from blocks
(using_terms_block
  "using" @open
  "end" @close)
