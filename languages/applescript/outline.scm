; Handler definitions show in outline
(handler_definition
  name: (identifier) @name) @item

; Property declarations show in outline
(property_declaration
  name: (identifier) @name) @item

; Tell blocks with application targets show in outline
(tell_block
  target: (application_expression) @name) @item

; Tell blocks with identifier targets show in outline
(tell_block
  target: (identifier) @name) @item
