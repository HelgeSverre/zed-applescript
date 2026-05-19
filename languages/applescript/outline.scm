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

; ObjC-style handler defs aren't a separate node — they're handler_definitions
; with selector-like names. They're already captured by the rule above.

; `use` imports at top of file appear in outline so the reader can see what
; the script depends on at a glance.
(use_statement
  (string) @name) @item
