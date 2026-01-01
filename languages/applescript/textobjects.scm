; Text objects for AppleScript
; Enables vim-style text object selection

; Comments
(comment) @comment.around
(comment) @comment.inside

; Functions/handlers - @function.around for entire handler, @function.inside for body
(handler_definition) @function.around
(handler_definition) @function.inside

; Script blocks as "classes" - @class.around for entire script, @class.inside for body
(script_block) @class.around
(script_block) @class.inside

; Additional block selections for navigation
(tell_block) @function.around
(tell_simple_statement) @function.around
(if_block) @function.around
(if_simple_statement) @function.around
(repeat_block) @function.around
(try_block) @function.around
(considering_block) @function.around
(ignoring_block) @function.around
(timeout_block) @function.around
(using_terms_block) @function.around
