; Run entire AppleScript file
; @run marks where the play button appears in the gutter
(source_file) @run @applescript-script

; Optionally run individual handlers
; Handler name is captured for the task label
(handler_definition
  name: (identifier) @_name) @run @applescript-handler
