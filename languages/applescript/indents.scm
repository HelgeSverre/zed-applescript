; Indentation rules for AppleScript blocks

; Blocks that increase indentation
(handler_definition) @indent
(script_block) @indent
(tell_block) @indent
(if_block) @indent
(else_if_clause) @indent
(else_clause) @indent
(repeat_block) @indent
(try_block) @indent
(error_handler) @indent
(considering_block) @indent
(ignoring_block) @indent
(timeout_block) @indent

; Dedent on block end keywords
(keyword_end) @outdent
