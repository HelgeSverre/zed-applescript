# External-scanner lessons learned

Concrete things discovered while implementing [`src/scanner.c`](https://github.com/HelgeSverre/tree-sitter-applescript/blob/main/src/scanner.c). Read this before extending the scanner — every item below took meaningful debugging time.

## 1. Whitespace handling is per-token, not global

If your scanner skips newlines at the top of `scan()`, every external token gets line-blind. That's correct for `block_comment` (we *want* it to see `(* … *)` anywhere) but wrong for tokens that should respect line boundaries.

Fix: gate the newline skip on `valid_symbols[BLOCK_COMMENT]`. Other tokens get only space/tab skipping.

```c
if (valid_symbols[BLOCK_COMMENT]) {
    // Skip everything, including newlines, so we reach `(`.
    while (lookahead == ' ' || lookahead == '\t'
        || lookahead == '\n' || lookahead == '\r'
        || lookahead == 0x00AC) skip(lexer);
    if (lookahead == '(') return scan_block_comment(lexer);
}
// For other tokens: skip only space/tab so newlines stay significant.
while (lookahead == ' ' || lookahead == '\t') skip(lexer);
```

## 2. The internal lexer races you

If your scanner returns false from a position the internal lexer can also handle, the internal lexer wins. Block-comment scanning has to skip leading whitespace itself; otherwise the lexer consumes `(` as a literal `(` token first and your scanner is called from a position past `(`.

Symptom: `scan()` is called repeatedly with `lookahead` advancing one character at a time, never returning true.

## 3. Once you `advance`, you can't rewind within the same scan call

The scanner's `advance()` is committed. If you advance through 5 chars of `alias`, then realize the next char isn't `of` — fine, you commit. But if you advance through 1 char of `alias`, realize the second char is `n` not `l`, and `return false` — you've still advanced. The next external token tried in the *same `scan()` call* sees position `nd`, not `and`.

This bit us hard: a `compound_word` token tried after a failed `alias_prefix` saw `nd` instead of `and` and accepted it.

**Rule**: try only ONE external token per scan call. If one starts and fails, return false from the whole function. Tree-sitter will call `scan()` again from a fresh position with different `valid_symbols`.

```c
// DON'T:
if (valid[A] && first_char_matches_A) {
    if (scan_A(lexer)) return true;
    // Fall through — wrong, lexer has advanced.
}
if (valid[B]) return scan_B(lexer);

// DO:
if (valid[A] && first_char_matches_A) return scan_A(lexer);
if (valid[B]) return scan_B(lexer);
```

## 4. Use `mark_end` to control token length without committing

If you need to look ahead past the token's actual content (e.g. peek for `of` after `alias` to decide whether to emit `alias_prefix`):

1. Advance through the token body.
2. Call `lexer->mark_end(lexer)` — fixes the token's end at the current position.
3. Continue advancing to peek.
4. Return true (or false), but the token's reported text is what was marked.

```c
// Consume `alias`.
for (int i = 0; i < 5; i++) advance(lexer);
// Mark end here — `alias` is the token boundary regardless of how far we peek.
lexer->mark_end(lexer);
// Peek for `of`, deciding whether to emit alias_prefix or not.
```

## 5. The tree-sitter cache lies if you don't clear it

`tree-sitter test` caches the built dylib at `~/Library/Caches/tree-sitter/lib/applescript*`. After ANY scanner change, run:

```bash
rm -rf ~/Library/Caches/tree-sitter
```

Without this you can spend hours wondering why your edits don't take effect.

## 6. Reserved-word filtering inside identifiers is harder than it looks

The natural idea: emit a `compound_word` token that matches an identifier only if the word isn't a reserved AppleScript keyword (`if`, `else`, `end`, etc.). Use it in `compound_name`'s optional trailing slots to stop multi-word names from greedily spanning newlines.

**This was prototyped and reverted** (commit `5d907bf`). Why it failed:

- AppleScript app dictionaries use many keyword-shaped words as legitimate property/element names: `down`, `up`, `option`, `front`, `back`, `every`, `some`, `all`, `last`, `first`, `middle`, `current`. Restricting any of these breaks real Folder Action scripts.
- The set of words that ACTUALLY cause cascades (`if`, `else`, `end`, `tell`, `try`, `repeat`, `on`, `to`, `set`, `copy`, `and`, `or`, `is`) is small, but the cascades they cause depend on column position and what came before on the line. Filtering by word-text alone over-rejects.

A proper fix would be column-/position-aware, tracking "are we at the start of a statement?" — but that requires threading scanner state through serialize/deserialize and gets cross-cutting.

If you revisit this, the design probably looks like:

- Track `at_line_start` boolean in scanner state.
- Reset it to true on `\n`, false on first non-whitespace character of a line.
- A `compound_word` external token rejects ONLY the small list of statement-head keywords AND ONLY when `at_line_start` is true.

That's a real project. The 10 corpus errors that remain today are all variations on this theme — they're documented in the README and acceptable for now.

## 7. Empty/stateless scanners still need all five external-scanner functions

Even if you don't need state:

```c
void *tree_sitter_applescript_external_scanner_create(void) { return NULL; }
void tree_sitter_applescript_external_scanner_destroy(void *p) { (void)p; }
unsigned tree_sitter_applescript_external_scanner_serialize(void *p, char *b) {
    (void)p; (void)b; return 0;
}
void tree_sitter_applescript_external_scanner_deserialize(void *p, const char *b, unsigned n) {
    (void)p; (void)b; (void)n;
}
bool tree_sitter_applescript_external_scanner_scan(void *p, TSLexer *l, const bool *vs) {
    // ... real logic ...
}
```

Forgetting one symbol gives a link error that doesn't always surface clearly in `tree-sitter test`.

## 8. Debugging is print statements

Tree-sitter has no scanner debugger. Use:

```c
#include <stdio.h>
#include <stdlib.h>
#define SCAN_DEBUG(...) do { if (getenv("AS_SCANNER_DEBUG")) fprintf(stderr, __VA_ARGS__); } while (0)
```

Then `AS_SCANNER_DEBUG=1 npx tree-sitter parse /tmp/test.applescript` shows you exactly what the scanner sees.

The `--debug` flag on `tree-sitter test` / `tree-sitter parse` also dumps `lex_external` / `lex_internal` decisions — invaluable for seeing why a token isn't emitted.
