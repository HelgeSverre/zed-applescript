; Syntactic scopes — tell Zed which regions are strings/comments so it
; can suppress autocomplete, switch spell-check on, prevent bracket auto-
; pairing inside strings, etc. Distinct from `highlights.scm` (which is
; about color); scopes affect editor BEHAVIOR.
;
; `.inclusive` means the scope includes the surrounding punctuation
; (the `--` / `(* *)` for comments and the `"…"` quotes for strings).

[
  (comment)
  (block_comment)
] @comment.inclusive

(string) @string
