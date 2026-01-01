; Outline/symbol support for AppleScript
; Shows handlers, scripts, and properties in the symbol outline panel

; Handler definitions with parameter context
(handler_definition
  name: (identifier) @name
  (parameter_list)? @context) @item

; Script blocks (named script objects)
(script_block
  name: (identifier) @name) @item

; Property declarations
(property_declaration
  name: (identifier) @name) @item

; Tell blocks show target in outline for navigation
(tell_block
  (reference
    (string) @context)) @item
