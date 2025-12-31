; Text objects for AppleScript
; Enables vim-style text object selection

; Comments
(comment) @comment.around
(comment) @comment.inside

; Strings
(string) @string.around
(string) @string.inside

; Functions/handlers
(handler_definition) @function.around
(handler_definition
  name: (identifier)
  (parameter_list)? @function.inside)

; Blocks
(tell_block) @block.around
(if_block) @block.around
(repeat_block) @block.around
(try_block) @block.around
