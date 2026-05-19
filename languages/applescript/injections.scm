; Language injections — embed other languages inside AppleScript strings.

; `do shell script "..."` runs the string as a shell command. Inject bash
; into the string body so users get shell highlighting inside it.
;
; Note: the grammar exposes the string content only as the literal `string`
; node, so the whole quoted argument (including the outer quotes) is what
; we hand off; Zed's bash highlights still render usefully for the body.
(command_call
  command: (command_name) @_cmd
  argument: (string) @injection.content
  (#match? @_cmd "(?i)^do\\s+shell\\s+script$")
  (#set! injection.language "bash"))

; `run script "..."` runs the string as AppleScript itself — recursive
; injection.
(command_call
  command: (command_name) @_cmd
  argument: (string) @injection.content
  (#match? @_cmd "(?i)^run\\s+script$")
  (#set! injection.language "applescript"))
