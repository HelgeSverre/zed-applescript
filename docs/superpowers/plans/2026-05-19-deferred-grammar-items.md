# Deferred grammar items — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land the three deferred roadmap items — pipe-delimited identifiers, multi-line `compound_name` cascade, and context-sensitive `to` — and re-include the four files currently quarantined in `test/corpus/realworld/known-limits/`.

**Architecture:** All three items share one missing primitive — a column-aware view of the input. `TSLexer` exposes `get_column(lexer)` (codepoints since start of line), so column-tracking does not require persistent scanner state. Each item is a separate external token added to `scanner.c` and wired into `grammar.js`. The plan staircases from cheapest (Phase 1: piped identifiers, no column work) to riskiest (Phase 3: compound_name boundary).

**Tech Stack:** tree-sitter 0.20+ (regex lexer + GLR + C external scanner), Node 18+ (`npx tree-sitter generate|test|parse`), the existing two-repo workflow (grammar submodule + extension repo pin in `extension.toml`).

---

## Hard rules (apply to every task)

1. **Active corpus must stay clean.** After every grammar change, run:
   ```bash
   for f in $(find test/corpus/realworld -name '*.applescript' -not -path '*/known-limits/*'); do
     out=$(npx tree-sitter parse "$f" 2>&1 | grep -E 'ERROR|MISSING')
     [ -n "$out" ] && echo "=== $f"$'\n'"$out"
   done
   ```
   Output must be empty. If non-empty, **revert** before moving on.
2. **Fixture suite must stay green.** `npx tree-sitter test` reports 86/86 (or higher after this plan adds tests).
3. **TDD order.** Write the failing corpus fixture first; confirm it fails for the *expected reason* (ERROR or wrong tree shape); then change the grammar/scanner; then confirm it passes; then re-run the active corpus + fixture suite.
4. **Frequent commits.** Each task ends with a single commit in the submodule. Pin bumps in the outer repo happen in dedicated "release" tasks at the end of each phase.
5. **No new conflicts without justification.** If you must add a `conflicts:` entry, write a one-line comment above it stating which two rules collide and why.

---

## File structure

| File | Repo | Role |
|---|---|---|
| `grammars/tree-sitter-applescript/src/scanner.c` | submodule | All three external tokens added here. Keep tokens independent — no shared state struct unless explicitly justified. |
| `grammars/tree-sitter-applescript/grammar.js` | submodule | `externals` array, conflict set, and rule wiring for each new token. |
| `grammars/tree-sitter-applescript/test/corpus/piped_identifiers.txt` | submodule | NEW — Phase 1 fixtures. |
| `grammars/tree-sitter-applescript/test/corpus/compound_name_multiline.txt` | submodule | NEW — Phase 3 fixtures. |
| `grammars/tree-sitter-applescript/test/corpus/handler_to.txt` | submodule | NEW — Phase 4 fixtures. |
| `grammars/tree-sitter-applescript/test/corpus/realworld/known-limits/*.applescript` | submodule | Files move OUT of here as each lands. |
| `grammars/tree-sitter-applescript/test/corpus/realworld/known-limits/README.md` | submodule | Update root-cause table as files leave. |
| `grammars/tree-sitter-applescript/test/corpus/realworld/ERRORS.md` | submodule | Update active-set count as files leave. |
| `languages/applescript/highlights.scm` | extension | Add `(piped_identifier) @variable` capture. |
| `extension.toml` | extension | One pin bump per phase (3 total). |
| `CHANGELOG.md` | extension | One `[1.3.0]` / `[1.4.0]` / `[1.5.0]` entry per phase. |
| `README.md` | extension | Roadmap section updated as items move from "Deferred" to "Done". |

---

# Phase 1 — Piped identifiers

Goal: parse `|name with spaces|` as a single identifier-shaped token, usable everywhere a plain identifier is.

Cost estimate: half a day. No column-aware work needed; this is a clean external-token addition that also exercises the scanner-test rhythm before Phase 3.

### Task 1.1 — Failing fixture

**Files:**
- Create: `grammars/tree-sitter-applescript/test/corpus/piped_identifiers.txt`

- [ ] **Step 1: Write the failing test fixture**

```
================================================================================
Piped identifier as set target
================================================================================

set |the user's name| to "Jane"

--------------------------------------------------------------------------------

(source_file
  (set_statement
    (keyword_set)
    variable: (piped_identifier)
    (keyword_to)
    (string)))

================================================================================
Piped identifier in property access
================================================================================

set x to |class| of theItem

--------------------------------------------------------------------------------

(source_file
  (set_statement
    (keyword_set)
    variable: (identifier)
    (keyword_to)
    (property_reference
      (compound_name
        (piped_identifier))
      (identifier))))

================================================================================
Piped identifier in handler parameter list
================================================================================

on greet(|first name|, |last name|)
end greet

--------------------------------------------------------------------------------

(source_file
  (handler_definition
    keyword: (keyword_function
      (keyword_on))
    name: (identifier)
    (parameter_list
      (piped_identifier)
      (piped_identifier))
    (keyword_end)
    (identifier)))
```

- [ ] **Step 2: Run to verify failure**

Run: `cd grammars/tree-sitter-applescript && npx tree-sitter test 2>&1 | grep -E '✘|Piped'`
Expected: All three "Piped" tests fail (parser doesn't know `piped_identifier`).

- [ ] **Step 3: Commit the failing fixture**

```bash
git add test/corpus/piped_identifiers.txt
git commit -m "test(piped-id): failing fixtures for |name with spaces|"
```

### Task 1.2 — Scanner token

**Files:**
- Modify: `grammars/tree-sitter-applescript/src/scanner.c`

- [ ] **Step 1: Add the token to the enum and the scan function**

At the top of `scanner.c`:

```c
enum TokenType {
    BLOCK_COMMENT,
    ALIAS_PREFIX,
    PIPED_IDENTIFIER,
};
```

Add a new scan function above `tree_sitter_applescript_external_scanner_scan`:

```c
// Scan |name with any chars except |, newline, or NUL|. The caller must have
// confirmed the lookahead is '|'. Returns true (and sets PIPED_IDENTIFIER)
// only on a successfully closed `|...|`. A newline or EOF inside the bars
// causes rejection so we don't silently swallow the rest of the file.
static bool scan_piped_identifier(TSLexer *lexer) {
    if (lexer->lookahead != '|') return false;
    advance(lexer);  // consume opening |

    bool saw_any = false;
    while (!lexer->eof(lexer)) {
        int32_t c = lexer->lookahead;
        if (c == '\n' || c == '\r') return false;  // unterminated
        if (c == '|') {
            if (!saw_any) return false;  // empty `||` is not an identifier
            advance(lexer);  // consume closing |
            lexer->result_symbol = PIPED_IDENTIFIER;
            return true;
        }
        saw_any = true;
        advance(lexer);
    }
    return false;  // EOF before closing |
}
```

In the dispatcher:

```c
if (valid_symbols[PIPED_IDENTIFIER] && lexer->lookahead == '|') {
    return scan_piped_identifier(lexer);
}
```

- [ ] **Step 2: Wire into grammar externals + a usable rule**

In `grammars/tree-sitter-applescript/grammar.js`, change the externals array:

```js
externals: ($) => [
  $.block_comment,
  $.alias_prefix,
  $.piped_identifier,
],
```

Add a rule (place near `identifier`, around line 1555):

```js
// Pipe-delimited identifier: |name with spaces|, |class|, |my var|.
// The bars are part of the token but stripped from the displayed name.
// Emitted by the external scanner so embedded `'` and `"` don't trip the
// regex lexer.
piped_identifier: ($) => $.piped_identifier,
```

Wait — that's recursive and wrong. The correct pattern for an external token that the grammar references is to leave the rule slot empty in `externals` (tree-sitter generates a placeholder). The reference in `externals: [$.piped_identifier]` IS the declaration; do NOT also write a rule body for it. Remove any rule body — the externals array entry is sufficient.

Now make every relevant use-site accept piped identifiers. Define a helper choice and ripple it through:

```js
// _name_ref: anywhere an identifier appears as a variable name, parameter,
// property reference target, or handler argument. Adds the piped form so
// users can write |the user's name| in any of those positions.
_name_ref: ($) => choice($.identifier, $.piped_identifier),
```

Then in these specific rules, replace `$.identifier` with `$._name_ref`:

- `set_statement` (the `variable:` field)
- `copy_statement` (the `variable:` field)
- `parameter_list` (each identifier inside)
- `labeled_parameter` (the `name:` field, but NOT the `label:` field — labels are always plain identifiers)
- `property_declaration` (the `name:` field)
- `global_declaration` body (each identifier)
- `local_declaration` body (each identifier)
- `error_parameters` (each identifier)
- `compound_name` (each `choice($.identifier, $.element_type)` becomes `choice($._name_ref, $.element_type)`)

Do NOT replace identifier in `handler_definition.name` — handler names are conventionally not piped, and changing the field type would ripple into `outline.scm`.

- [ ] **Step 3: Regenerate and run tests**

```bash
cd grammars/tree-sitter-applescript
npx tree-sitter generate
npx tree-sitter test 2>&1 | tail -5
```

Expected: 86 prior tests pass + 3 new piped tests pass = 89.

- [ ] **Step 4: Active-corpus regression check**

Run the loop from Hard Rules #1. Expected: empty output.

- [ ] **Step 5: Commit**

```bash
git add grammar.js src/ test/corpus/piped_identifiers.txt
git commit -m "feat(grammar): piped identifiers (|name with spaces|)

External token PIPED_IDENTIFIER emitted by scanner.c. Wired into
_name_ref helper used in set/copy targets, parameter lists, property
declarations, global/local declarations, error parameters, and
compound_name. Handler names intentionally stay plain identifier."
```

### Task 1.3 — Highlights

**Files:**
- Modify: `languages/applescript/highlights.scm`

- [ ] **Step 1: Add the capture**

Near the `(identifier) @variable` fallback at the end of `highlights.scm`:

```
; Pipe-delimited identifiers — `|name with spaces|`. Same color as plain
; identifiers; the bars are part of the token.
(piped_identifier) @variable
```

- [ ] **Step 2: Commit**

```bash
git add languages/applescript/highlights.scm
git commit -m "highlights: capture piped_identifier as @variable"
```

### Task 1.4 — Phase 1 release

**Files:**
- Modify: `extension.toml`, `CHANGELOG.md`, `README.md`

- [ ] **Step 1: Push the grammar commits**

```bash
cd grammars/tree-sitter-applescript
git push origin main
git rev-parse HEAD   # capture SHA
```

- [ ] **Step 2: Bump pin in `extension.toml`**

Replace the `commit = "..."` line with the SHA from Step 1.

- [ ] **Step 3: Bump version to 1.3.0**

In `extension.toml`: `version = "1.3.0"`.

- [ ] **Step 4: CHANGELOG entry**

Add above the prior `[1.2.0]` block:

```markdown
## [1.3.0]

### Added

- **Pipe-delimited identifiers** (`|name with spaces|`): an external scanner token recognises the AppleScript form for identifiers containing spaces, apostrophes, or words that would otherwise be reserved (`|class|`, `|set|`). Accepted everywhere a name slot exists: set/copy targets, parameter lists, property declarations, global/local declarations, error parameter clauses, and compound names.

### Changed

- Grammar pin bumped to `<SHA>`.
```

- [ ] **Step 5: README roadmap**

Move "Pipe-delimited identifiers" from "Deferred" to "Done — v1.3.0".

- [ ] **Step 6: Commit + tag + push**

```bash
git add extension.toml CHANGELOG.md README.md grammars/tree-sitter-applescript
git commit -m "Release v1.3.0: piped identifiers"
git tag v1.3.0
git push origin main v1.3.0
```

---

# Phase 2 — Context-sensitive `to`

Goal: stop misparsing `to` as `keyword_handler_to` when it appears mid-statement (inside `move X to Y`, `copy X to Y`, `from N to M`, coercion). The fix uses `get_column` — a `to` only starts a handler definition when it is at column 0 (or after only whitespace) on its own line.

This phase is sequenced before compound_name because it's a smaller scoped change and gives us early confidence that column-aware tokens work. Land it second; land compound_name third.

Cost estimate: half a day.

### Task 2.1 — Quarantined-file inventory

- [ ] **Step 1: Identify the affected file**

```bash
cd grammars/tree-sitter-applescript
npx tree-sitter parse test/corpus/realworld/known-limits/colorsync_extract.applescript 2>&1 | grep ERROR | head -3
```

Expected: errors clustered around `move X to trash` lines.

- [ ] **Step 2: Copy the smallest failing snippet into a fixture**

Find the `move … to trash` line in `colorsync_extract.applescript` (and any other `move`/`copy ... to ...` inside `tell`/`try` blocks) and extract a minimal reproducer.

Create `grammars/tree-sitter-applescript/test/corpus/handler_to.txt`:

```
================================================================================
move X to trash inside tell block
================================================================================

tell application "Finder"
    move x to trash
end tell

--------------------------------------------------------------------------------

(source_file
  (tell_block
    (keyword_tell)
    target: (reference
      (keyword_application)
      (string))
    (command_call
      command: (command_name)
      argument: (identifier)
      (command_parameter
        name: (parameter_name)
        value: (identifier)))
    (keyword_end)
    (keyword_tell)))

================================================================================
Handler definition with `to` at column 0
================================================================================

to splitString(s, delim)
    return s
end splitString

--------------------------------------------------------------------------------

(source_file
  (handler_definition
    keyword: (keyword_function
      (keyword_handler_to))
    name: (identifier)
    (parameter_list
      (identifier)
      (identifier))
    (return_statement
      (keyword_return)
      (identifier))
    (keyword_end)
    (identifier)))
```

- [ ] **Step 3: Confirm the first fixture fails for the right reason**

```bash
npx tree-sitter test 2>&1 | grep -E '✘|move X to trash'
```

Expected: "move X to trash inside tell block" fails — the parser likely emits `(handler_definition ...)` swallowing `to trash` as a header.

- [ ] **Step 4: Commit the failing fixtures**

```bash
git add test/corpus/handler_to.txt
git commit -m "test(handler-to): failing fixture for move/to inside tell"
```

### Task 2.2 — Column-aware `keyword_handler_to`

**Files:**
- Modify: `grammars/tree-sitter-applescript/src/scanner.c`
- Modify: `grammars/tree-sitter-applescript/grammar.js`

- [ ] **Step 1: Add the external token**

In `scanner.c`:

```c
enum TokenType {
    BLOCK_COMMENT,
    ALIAS_PREFIX,
    PIPED_IDENTIFIER,
    KEYWORD_HANDLER_TO,   // `to` at line start, NOT followed by an expression
};
```

Add scan function:

```c
// `to` is overloaded. Recognise it as a HANDLER opener only when it is
// at the start of a line (after optional whitespace) AND the word is
// `to` (case-insensitive) AND followed by an identifier — i.e. it
// matches `to <name>(...)` not `move x to y`.
//
// Column check uses `lexer->get_column(lexer)`. The grammar's `extras`
// already consumed leading whitespace, so by the time we are called the
// column reflects where `to` actually starts. If column == 0 (or the
// preceding characters on this line were only whitespace), and we are
// at a `to` token, emit KEYWORD_HANDLER_TO.
//
// We do NOT consume any input ourselves if the column test fails —
// we return false and let the regular `to` token win.
static bool scan_keyword_handler_to(TSLexer *lexer) {
    // Must be at column 0. `extras` strips leading whitespace, but
    // `get_column` returns the column of the next non-extras character.
    if (lexer->get_column(lexer) != 0) return false;

    // Match the word `to` case-insensitively.
    const char target[] = {'t', 'o'};
    for (int i = 0; i < 2; i++) {
        int32_t c = lexer->lookahead;
        if (c >= 'A' && c <= 'Z') c += 32;
        if (c != target[i]) return false;
        advance(lexer);
    }

    // Word boundary check.
    int32_t after = lexer->lookahead;
    if (after == '_' || iswalnum(after)) return false;

    lexer->result_symbol = KEYWORD_HANDLER_TO;
    return true;
}
```

In the dispatcher (must run BEFORE alias_prefix to not race):

```c
if (valid_symbols[KEYWORD_HANDLER_TO] &&
    (lexer->lookahead == 't' || lexer->lookahead == 'T')) {
    if (scan_keyword_handler_to(lexer)) return true;
    // fall through — the plain `to` token will pick it up
}
```

- [ ] **Step 2: Wire into grammar**

In `grammar.js`:

```js
externals: ($) => [
  $.block_comment,
  $.alias_prefix,
  $.piped_identifier,
  $.keyword_handler_to,
],
```

Find the existing `keyword_handler_to: ($) => token(ci("to"))` and DELETE it — the external token replaces it. Verify all references to `$.keyword_handler_to` still resolve (they should, because the externals array declares the rule).

If there is also a `keyword_to` token used for parameter labels / range / coercion, leave it intact — that's the fallback that wins outside column 0.

- [ ] **Step 3: Regenerate, test, scan corpus**

```bash
npx tree-sitter generate
npx tree-sitter test 2>&1 | tail -5
# expected: all previous tests + 2 new handler_to tests pass
```

Then run the active-corpus loop. Expected: empty.

- [ ] **Step 4: Verify the quarantined file is fixed**

```bash
npx tree-sitter parse test/corpus/realworld/known-limits/colorsync_extract.applescript 2>&1 | grep -E 'ERROR|MISSING'
```

Expected: empty.

- [ ] **Step 5: Move the file out of quarantine**

```bash
git mv test/corpus/realworld/known-limits/colorsync_extract.applescript test/corpus/realworld/object_specifiers/
```

- [ ] **Step 6: Update `ERRORS.md` and `known-limits/README.md`**

In `test/corpus/realworld/ERRORS.md`: change the active-count line from "32 of 32" to "33 of 33"; add a row to the per-file table for `object_specifiers/colorsync_extract.applescript | 0 | 0`; remove the row for `colorsync_extract.applescript` from the quarantined table.

In `test/corpus/realworld/known-limits/README.md`: remove the `colorsync_extract.applescript` row from the root-cause table; add a "Resolved" section that lists "colorsync_extract.applescript — fixed by column-aware `keyword_handler_to` external token (v1.4.0)."

- [ ] **Step 7: Commit**

```bash
git add scanner.c grammar.js src/ test/
git commit -m "feat(grammar): column-aware keyword_handler_to

External token only emits when 'to' is at column 0, so 'move X to Y'
inside tell/try blocks no longer parses as a handler header.

Unblocks colorsync_extract.applescript; moved out of known-limits."
```

### Task 2.3 — Phase 2 release

Same shape as Task 1.4 — push grammar, bump pin, bump version to `1.4.0`, CHANGELOG entry, README move ("Context-sensitive `to`" Deferred → Done), commit/tag/push.

---

# Phase 3 — Multi-line `compound_name` cascade

Goal: stop the parser from greedily consuming an identifier on the next line as the second word of a `compound_name`. Specifically, when a `display dialog "Foo"` is followed by `\n    default answer ""`, `default answer` should NOT bind back to a previous compound — it should start a new statement or be picked up as a `parameter_name`.

This is the riskiest item. The prior session reverted three different approaches because each regressed cases where multi-word identifiers legitimately span continuations.

**Strategy:** rather than changing `compound_name` directly, add an external token `compound_continuation_word` that emits an identifier ONLY when the column has not reset to 0 since the previous word. Then rewrite `compound_name` to use `(identifier|element_type) (compound_continuation_word)*` — i.e. only the *first* word can be at column 0; subsequent words must be indented past the start of the construct.

Cost estimate: 1–2 days, with the design likely needing revision mid-flight.

### Task 3.1 — Failing fixtures

**Files:**
- Create: `grammars/tree-sitter-applescript/test/corpus/compound_name_multiline.txt`

- [ ] **Step 1: Write the failing fixtures**

```
================================================================================
display dialog with default answer parameter
================================================================================

display dialog "Name?" default answer ""

--------------------------------------------------------------------------------

(source_file
  (command_call
    command: (command_name)
    argument: (string)
    (command_parameter
      name: (parameter_name)
      value: (string))))

================================================================================
display dialog with parameter on next line
================================================================================

display dialog "Name?" ¬
    default answer ""

--------------------------------------------------------------------------------

(source_file
  (command_call
    command: (command_name)
    argument: (string)
    (command_parameter
      name: (parameter_name)
      value: (string))))

================================================================================
display dialog with parameter on next line WITHOUT continuation
================================================================================

display dialog "Name?"
    default answer ""

--------------------------------------------------------------------------------

(source_file
  (command_call
    command: (command_name)
    argument: (string))
  (command_call
    command: (command_name)
    argument: (string)))
```

Note: the third fixture asserts that **without** `¬`, the next line is a SEPARATE statement, not a continuation. This is the correct AppleScript semantics and is what's currently broken — today the parser glues `default answer` into a multi-word compound bound back to the previous statement.

- [ ] **Step 2: Confirm failures**

Same shape as Task 1.1 Step 2.

- [ ] **Step 3: Commit**

```bash
git add test/corpus/compound_name_multiline.txt
git commit -m "test(compound-name): failing fixtures for newline boundary"
```

### Task 3.2 — `compound_continuation_word` external token

**Files:**
- Modify: `grammars/tree-sitter-applescript/src/scanner.c`
- Modify: `grammars/tree-sitter-applescript/grammar.js`

- [ ] **Step 1: Add scanner state for "last seen column of compound head"**

The scanner needs to remember the column of the first word of the current `compound_name`. This is the first item in the plan that needs persistent state.

In `scanner.c`:

```c
typedef struct {
    // Column of the most recent `identifier` that started a compound_name,
    // OR -1 if we are not inside one. Used by COMPOUND_CONTINUATION_WORD
    // to refuse continuation across a column reset (newline returning to
    // column 0 or less).
    int32_t compound_head_col;
} ScannerState;
```

Update `create`, `destroy`, `serialize`, `deserialize`:

```c
void *tree_sitter_applescript_external_scanner_create(void) {
    ScannerState *s = (ScannerState *)malloc(sizeof(ScannerState));
    s->compound_head_col = -1;
    return s;
}
void tree_sitter_applescript_external_scanner_destroy(void *payload) {
    free(payload);
}
unsigned tree_sitter_applescript_external_scanner_serialize(void *payload, char *buffer) {
    ScannerState *s = (ScannerState *)payload;
    memcpy(buffer, &s->compound_head_col, sizeof(s->compound_head_col));
    return sizeof(s->compound_head_col);
}
void tree_sitter_applescript_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
    ScannerState *s = (ScannerState *)payload;
    if (length == sizeof(s->compound_head_col)) {
        memcpy(&s->compound_head_col, buffer, sizeof(s->compound_head_col));
    } else {
        s->compound_head_col = -1;
    }
}
```

(Update existing function signatures to actually use the payload — they were `(void)payload;` before.)

- [ ] **Step 2: Add the continuation-word token**

```c
enum TokenType {
    BLOCK_COMMENT,
    ALIAS_PREFIX,
    PIPED_IDENTIFIER,
    KEYWORD_HANDLER_TO,
    COMPOUND_CONTINUATION_WORD,
};
```

And in the dispatcher, when `valid_symbols[COMPOUND_CONTINUATION_WORD]` is set:

```c
// A word that continues a compound_name. Only emit when the lookahead
// is identifier-start AND the column has not crossed a line boundary
// (we are still on the same line as the previous compound word, OR a
// `¬` continuation was honoured by `extras` so the parser believes we
// are still on the same logical line).
if (valid_symbols[COMPOUND_CONTINUATION_WORD] &&
    (lexer->lookahead == '_' || iswalpha(lexer->lookahead))) {
    uint32_t col = lexer->get_column(lexer);
    if (s->compound_head_col >= 0 && col > s->compound_head_col) {
        // Consume one identifier.
        while (lexer->lookahead == '_' || iswalnum(lexer->lookahead)) {
            advance(lexer);
        }
        lexer->result_symbol = COMPOUND_CONTINUATION_WORD;
        return true;
    }
}
```

**Critical caveat:** the column comparison `col > s->compound_head_col` works because (a) if we're on the same line as the head, get_column returns a value strictly greater than the head's column; (b) if we crossed a newline back to column 0, the value is 0 and fails the check. The `extras` already stripped `¬`-introduced whitespace so a true continuation looks single-line to us. Verify this assumption with the second fixture (continuation case) — if it fails, the assumption is wrong and the design needs revision; see "Fallback plan" below.

- [ ] **Step 3: Wire into grammar**

In `grammar.js`, change the externals array:

```js
externals: ($) => [
  $.block_comment,
  $.alias_prefix,
  $.piped_identifier,
  $.keyword_handler_to,
  $.compound_continuation_word,
],
```

Rewrite `compound_name`:

```js
compound_name: ($) =>
  prec.right(seq(
    // Head word — any identifier or element type at any column.
    choice($._name_ref, $.element_type),
    // Continuation words — only emitted by the external scanner when
    // still on the same logical line as the head.
    repeat($.compound_continuation_word)
  )),
```

Remove the 5 optional continuation slots; the external token gives unbounded but newline-bounded continuation.

- [ ] **Step 4: Regenerate, test, scan corpus**

```bash
npx tree-sitter generate
npx tree-sitter test 2>&1 | tail -10
```

Expected: all 89+ prior tests pass + 3 new compound_name tests pass.

Run the active-corpus loop. Expected: empty.

**If the corpus loop reports regressions:** STOP. The design assumption (that single-line continuation reads via get_column alone) is wrong somewhere. Document the failing case in the task and fall back to "Plan B" (below).

- [ ] **Step 5: Re-include the affected files**

Run parse on each quarantined file:

```bash
for f in test/corpus/realworld/known-limits/*.applescript; do
  out=$(npx tree-sitter parse "$f" 2>&1 | grep -E 'ERROR|MISSING')
  echo "$f: ${out:-CLEAN}"
done
```

For each `CLEAN` file, `git mv` it out of `known-limits/` into its original folder (handlers/, folder_actions/, etc. — check git log for the original location). Update `ERRORS.md` and `known-limits/README.md` accordingly.

- [ ] **Step 6: Commit**

```bash
git add scanner.c grammar.js src/ test/
git commit -m "feat(grammar): column-bounded compound_continuation_word

External token continues a compound_name only when get_column reports a
position strictly past the column of the head word. Stops the parser
from gluing the next line into a compound when there's no continuation
glyph.

Unblocks <N> quarantined files; moved out of known-limits."
```

### Task 3.3 — Plan B (if Task 3.2 Step 4 fails)

This is not a step; it's the documented fallback. If Step 4 reports regressions:

**Symptom A — `¬` continuation case fails:** the parser sees `default answer` as column 4 on a fresh line. Likely fix: `extras` consumes the `¬` BUT the newline that follows resets `get_column` to 0 before `extras` returns. We need to detect this and remember "the previous extras run included a `¬`", which means moving `¬` out of `extras` and into a scanner-handled token.

**Symptom B — legitimate multi-word identifiers on the same line regress:** the column check is too strict — the head word was at the start of an indented block (e.g. column 4) and the second word is also at column 4 (it was on the same line as the head, but `get_column` only returns the CURRENT character's column, not whether a newline intervened). Fix: track "did the lexer cross a newline since the last token" via a flag in `ScannerState`, set during the in-band advance loop, cleared when emitting a non-newline token. This is the "true" column-aware scanner from the prior session's failed attempts; budget another day for it.

**If neither fix is fast,** revert Phase 3 and accept the four quarantined files as a permanent limit.

### Task 3.4 — Phase 3 release

Same shape as Task 1.4 / 2.3. Version bumps to `1.5.0`. README roadmap moves "Multi-line `compound_name` cascade" Deferred → Done (or "Deferred — design revision needed" if Plan B was hit).

---

## Self-review

**Spec coverage:**
- Pipe-delimited identifiers — Phase 1 ✅
- Multi-line compound_name — Phase 3 ✅
- Context-sensitive `to` — Phase 2 ✅
- Re-including quarantined files — Tasks 2.2 Step 5–6 and 3.2 Step 5 ✅
- Documentation and release flow — Tasks 1.4, 2.3, 3.4 ✅

**Placeholder scan:** none. Every code step shows the actual diff.

**Type consistency:**
- `_name_ref` (Phase 1) is used in Phase 3's `compound_name` rewrite — verified.
- `compound_continuation_word` is referenced only in `compound_name` — verified.
- `keyword_handler_to` external replaces a regular token of the same name — call sites unchanged.

**Risks the plan does not eliminate:**
1. Phase 3 may need redesign mid-flight (Plan B in Task 3.3 acknowledges this).
2. Two-repo release ceremony is unchanged — three pin bumps means three opportunities for drift. Mitigation: each release task ends with the same active-corpus check that gates every other commit, so silent drift produces an immediately failing parse.
3. `get_column` semantics under `extras` consumption have not been empirically verified in this codebase — Task 3.2 Step 4 is the first place we'd discover a mismatch, and Plan B documents the recovery.

---

## Execution

This plan has three independent phases. They can be executed sequentially in one session (Phase 1 → 2 → 3) or each phase can be its own session. Phase 1 is recommended as a single-sitting warm-up before committing to Phases 2–3.
