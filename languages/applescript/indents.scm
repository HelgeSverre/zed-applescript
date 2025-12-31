; Indentation rules for AppleScript blocks

; Blocks that increase indentation
(handler_definition) @indent
(tell_block) @indent
(if_block) @indent
(repeat_block) @indent
(try_block) @indent
(else_clause) @indent
(error_handler) @indent

; Dedent on block end keywords
(keyword_end) @outdent
