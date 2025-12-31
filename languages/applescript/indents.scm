; Indent after block openers
[
  (handler_definition)
  (tell_block)
  (if_statement)
  (else_if_clause)
  (else_clause)
  (repeat_statement)
  (try_statement)
  (on_error_clause)
  (with_timeout_block)
  (with_transaction_block)
  (considering_block)
  (ignoring_block)
  (using_terms_block)
] @indent

; Dedent on end keywords
"end" @outdent

; Dedent on else
"else" @outdent

; Branch for else if
(else_if_clause) @branch

; Branch for else
(else_clause) @branch

; Branch for on error
(on_error_clause) @branch
