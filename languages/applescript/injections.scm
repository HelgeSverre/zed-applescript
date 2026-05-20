; Language injections — embed other languages inside AppleScript code.

; Inject the `comment` pseudo-language inside every comment so Zed's
; built-in TODO/FIXME/NOTE/HACK gutter highlighting fires for AppleScript
; sources. Covers both line (`--`, `#`) and block (`(* *)`) comment forms.
((comment) @injection.content
  (#set! injection.language "comment"))
((block_comment) @injection.content
  (#set! injection.language "comment"))

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

; `run script "..."` accepts either AppleScript source or JavaScript for
; Automation (JXA). We inject AppleScript by default and switch to
; JavaScript when the string body has JS-shaped tokens near the start —
; `function`, `var`/`let`/`const` declarations, `=>` arrows, `//` line
; comments, or `Application(` calls (the JXA entry point). The two rules
; are mutually exclusive via opposing #match? / #not-match? predicates,
; so each string body matches exactly one.
(command_call
  command: (command_name) @_cmd
  argument: (string) @injection.content
  (#match? @_cmd "(?i)^run\\s+script$")
  (#match? @injection.content "(?s)(\\bfunction\\s*[*(]|\\b(?:var|let|const)\\s+\\w|=>|//|\\bApplication\\s*\\()")
  (#set! injection.language "javascript"))

(command_call
  command: (command_name) @_cmd
  argument: (string) @injection.content
  (#match? @_cmd "(?i)^run\\s+script$")
  (#not-match? @injection.content "(?s)(\\bfunction\\s*[*(]|\\b(?:var|let|const)\\s+\\w|=>|//|\\bApplication\\s*\\()")
  (#set! injection.language "applescript"))
