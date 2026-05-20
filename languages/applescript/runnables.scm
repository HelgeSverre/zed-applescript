; Run entire AppleScript file
; @run marks where the play button appears in the gutter
(source_file) @run @applescript-script

; Optionally run individual handlers.
; The `@name` capture (no underscore) is what Zed's runnable system
; substitutes into `$ZED_SYMBOL` in tasks.json. A leading underscore
; would have marked it as internal/unused and the substitution would
; silently produce a blank handler name.
(handler_definition
  name: (identifier) @name) @run @applescript-handler
