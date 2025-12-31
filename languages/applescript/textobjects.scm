; Function/handler text objects
(handler_definition) @function.around
(handler_definition
  name: (identifier)
  (parameter_list)?
  . (_)* @function.inside
  "end")

; Block text objects
(tell_block) @block.around
(if_statement) @block.around
(repeat_statement) @block.around
(try_statement) @block.around

; Comment text objects
(comment) @comment.around
(comment) @comment.inside

; Parameter text objects
(parameter_list) @parameter.around
(parameter) @parameter.inside
