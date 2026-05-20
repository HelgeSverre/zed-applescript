# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.8.5]

Corpus expansion — 9 community-sourced scripts.

### Added

- **Active corpus → 40 files** (was 36). Four community scripts that already parse cleanly:
  - `community/dmg_finder.applescript` from `indygreg/PyOxidizer` — Finder DMG window-styling pattern.
  - `community/NV-CopyToNV.applescript`, `community/NV-LinkAutomation.applescript`, `community/NV-NewNoteFromDialog.applescript` from `unforswearing/applescript` — Notational Velocity automation snippets.
- **Stress targets in `known-limits/community-stress/`** — 5 substantial files (1,155 LOC total, 69 ERROR nodes) that exercise gaps not yet covered:
  - `omnifocus_library.applescript` (579 LOC, 29 err) — multi-word record keys, deep ASObjC patterns.
  - `battery_monitor.applescript` (228, 12) — long mixed-pattern app.
  - `layouts.applescript` (148, 7) — chained tells, window management.
  - `adium_unittest.applescript` (106, 11) — Adium app-dictionary specifics.
  - `alfred_iterm.applescript` (94, 10) — `tell X to tell Y to tell Z to <action>` chains.

  Each is documented in [`known-limits/README.md`](https://github.com/HelgeSverre/tree-sitter-applescript/blob/main/test/corpus/realworld/known-limits/README.md) with its primary failure mode, so future grammar work can pick the highest-leverage target.

### Changed

- Grammar pin bumped to `b523b13`. No parser change — corpus addition only.

## [1.8.4]

Polish pass — four small additions, no behavior changes for end users.

### Added

- **CI on the grammar repo** at [HelgeSverre/tree-sitter-applescript](https://github.com/HelgeSverre/tree-sitter-applescript/actions). Runs the fixture suite + a real-world corpus scan on every push and PR to grammar `main`. Catches regressions before they leave the grammar repo, so a broken grammar can't silently slip in via the next `just update-grammar` here.
- **`just status`** recipe — prints version, grammar pin, last tag, and whether the submodule SHA matches the pin (with a `⚠` if it doesn't). Useful when context-switching back to the repo.
- **README badges** for CI status, latest version, and license.

### Changed

- README's `Documentation` section now lists only user-facing material (CHANGELOG, the references cache). Moved `CLAUDE.md` into a new `Contributing` section since it's a repo-internal contract for AI agents, not user-facing documentation.
- Grammar pin bumped to `0083acc` to pick up the new CI workflow on the grammar side. No parser change.

## [1.8.3]

Eight findings from a five-lens swarm review applied as a single batch.

### Fixed

- **`$ZED_SYMBOL` no longer flows into a `bash -c` string** in the "Run handler" task. It's now passed as an environment variable (`HANDLER`) and read as a normal shell variable, eliminating the textual-injection risk a maliciously named handler could otherwise exploit. (Security audit.)
- **`mktemp` leak in the handler task closed.** The previous one-liner appended `.applescript` to `$(mktemp …)`, leaving the original temp file un-deleted on every run. Now uses `mktemp` + `mv` + `trap … EXIT` for guaranteed cleanup. (Code review.)
- **`runnables.scm` handler-name capture renamed `@_name` → `@name`** so Zed actually populates `$ZED_SYMBOL` in the task label. The leading-underscore convention marks a capture as internal/unused, which on some Zed builds suppressed the substitution silently. (Code review.)
- **`just test` no longer truncates its output** with `| tail -3`. CI failures now show which fixture broke and the diff, not just the summary count. (Code review.)
- **`just release` uses explicit `git add` paths** (`extension.toml`, `grammars/tree-sitter-applescript`, `CHANGELOG.md`) instead of `git add -A`, so a release commit can't sweep in stray local files. (Security audit.)
- **`tree-sitter-cli@0.22` pinned in CI** (`ci.yml` + `release.yml`). The previous unpinned `npm install -g tree-sitter-cli` would have broken silently on a major-version bump. (Maintenance forecast.)

### Added

- **Comment language injection** (`injections.scm`): both `(comment)` and `(block_comment)` now inject Zed's `comment` pseudo-language, activating built-in TODO/FIXME/NOTE/HACK gutter highlighting. (Comparative analysis vs Dart/Haskell/Lua.)
- **GitHub topics** on the extension repo (`zed-editor`, `zed-extension`, `osascript`, `automation`, `tree-sitter`, `macos`, `applescript`, `zed`) and a clearer description that drops the misleading `(WIP)` prefix at v1.8.3. (Outside-skeptic review.)

## [1.8.2]

### Added

- **Grammar repo README + LICENSE** at [HelgeSverre/tree-sitter-applescript](https://github.com/HelgeSverre/tree-sitter-applescript). The grammar previously shipped without a README. Also set its GitHub topics (`tree-sitter`, `tree-sitter-grammar`, `tree-sitter-parser`, `parser`, `applescript`, `osascript`, `macos`, `automation`), updated the description, and set the homepage to point at this extension.
- Grammar pin bumped to include the new README/LICENSE (no parser change).

### Changed

- **CI workflow** now runs `just verify` and `just test` instead of an ad-hoc inline parse, so the .scm-against-node-types check gates every push.
- **Release workflow** runs `just verify` as a pre-publish gate.
- Both workflows now use `actions/checkout@v4` with `submodules: recursive` so the grammar is available without an extra clone step, and install `just` via `extractions/setup-just@v2`.
- LICENSE.md copyright year bumped to 2026.

## [1.8.1]

### Added

- **`example/` directory** with three smoke-test files: `hello.applescript` (minimal), `showcase.applescript` (exercises every construct the extension highlights), and `injection.md` (markdown fence injection check).
- **`just install`** symlinks this directory into `~/Library/Application Support/Zed/extensions/installed/applescript`. Idempotent. Replaces the prior print-instructions placeholder.
- **`just dev`** verifies queries and opens the `example/` folder in a new Zed window — the one-command "see my change" entry point.
- **`just install-via-ui`** retains the old print-instructions flow for fresh contributors who'd rather have Zed compile the extension through its own builder.

### Changed

- README trimmed (219 → 123 lines). Per-release historical notes moved to this CHANGELOG; the support matrix, grammar coverage table, and dev workflow are kept and tightened.
- `justfile` recipe descriptions cleaned up so `just --list` is readable.
- Deleted on-disk leftovers (`grammars/applescript/`, `grammars/applescript.wasm`) — both were already gitignored runtime artifacts.

## [1.8.0]

### Added

- **`overrides.scm`** — declares syntactic scopes (`@string`, `@comment.inclusive` covering both `(comment)` and `(block_comment)`). Lets Zed suppress autocomplete inside comments, enable spell-check inside strings vs disable elsewhere, and skip bracket-pair insertion inside string literals. This was the only documented language-query file we were missing.
- **`autoclose_before = ";:.,=}])>"`** in `config.toml` — typing an opening bracket immediately before any of these characters will still autoclose, matching the convention used across Elixir, Kotlin, and other popular Zed extensions.
- **Compile-to-.scpt task** — gutter task "Compile to .scpt" runs `osacompile -o <file>.scpt <file>` for the script. Pairs with the existing "Run AppleScript" and "Run handler $ZED_SYMBOL" runnables.

### Verified

- **Markdown fence injection works.** Zed's language registry uses case-insensitive lookup against `name` ("AppleScript") and `path_suffixes` (`"applescript"`, `"scpt"`), so ```applescript`, ```AppleScript`, and ```scpt` all trigger our highlights inside markdown documents — no extra configuration needed in this extension. Verified by reading `crates/language/src/language_registry.rs::language_for_name_or_extension` in Zed's source.

### Reviewed against other extensions

Surveyed 10 popular language extensions (F#, Haskell, Elixir, Dart, Elm, Kotlin, Gleam, Lua, Nix, Crystal) — see CHANGELOG for v1.7.3. With this release we now ship 8 of the 9 documented Zed `.scm` files (everything except `redactions.scm`, which is for PII/secret masking and doesn't apply to AppleScript).

## [1.7.3]

### Fixed

- **`block_comment` text object capture.** `(comment)` was captured for the line-comment form but `(block_comment)` (the `(* ... *)` form) wasn't, so vim's `gc` text object didn't land on block comments. Added `(block_comment) @comment.around` and `@comment.inside`. Adjacent line comments now join into a single text object via `(comment)+` (Zed convention).

### Known limitation — block comment folding

Zed does not currently expose any tree-sitter query for code folding (no `folds.scm` convention; folding is driven only by indentation and LSP folding ranges). A top-of-file `(* ... *)` block comment with column-0 content has no indentation change for Zed's folder to latch onto, so multi-line block comments are not foldable from this extension's side. This is a Zed limitation, not a grammar one — would require an upstream change to add a fold-query convention.

## [1.7.2]

### Fixed

- **Block comments now highlight.** `(* ... *)` block comments were a separate `block_comment` node, but `highlights.scm` only captured the line-comment `(comment)` node. Result: every block comment in every script rendered with no syntax color. Added `(block_comment) @comment` capture. This bug pre-dates v1.0 and is the first user-reported bug of the session.

### Known limitation

- `just verify` catches dead .scm node references (the inverse direction), but NOT named nodes that exist in the grammar yet have no `.scm` capture (like this bug). Strengthening verify to flag uncaptured named nodes would need a curated allowlist (many nodes legitimately stay uncaptured — control-flow wrappers, etc.). Worth doing if more capture gaps surface.

## [1.7.1]

### Added

- **`just verify`** — regenerates the grammar and checks every node reference in `languages/applescript/*.scm` against the freshly-generated `src/node-types.json`. Fails on unknown nodes. Wired into `just release` as a pre-tag gate so silent `.scm`/grammar drift can't ship.

### Fixed

- Removed dead `(escape_sequence) @string.escape` query — the rule was unused in `grammar.js` (since `string` was made opaque), so tree-sitter had been stripping it from the generated parser. The query had been a silent no-op. Grammar pin bumped to `1d74fe0` (orphan rule deleted).
- `.gitignore` now excludes `grammars/applescript/`, the Zed dev-extension runtime artifact that was repeatedly sneaking back in as a duplicate gitlink via `git add -A`.

## [1.7.0]

### Added

- **`if_simple_statement` tail widened** to also accept `set_statement`, `copy_statement`, `command_call`, and `tell_simple_statement` — not just the original 5 atomic forms (return/exit/continue/error/log). Safe because `inline_marker` (v1.6.0) already constrains the tail to the same logical line. Eliminates the previously-documented "one-liner gap" — `if cond then say "hi"` and `if cond then set x to 5` now parse correctly without synthesising `MISSING keyword_end`.
- **`index_expression` accepts `keyword_script`** as an alternative to `element_type`. The lexer always emits `keyword_script` for the bare word `script`, which previously made commands like `delete script X of folder action Y` (common in folder-action scripts) unparseable — `script` was unreachable from `element_type`'s alternatives.

### Fixed

- Last quarantined file resolved. `remove_folder_actions.applescript` now parses cleanly and is in the active corpus. **`known-limits/` is empty.** Active corpus is **36/36** with 0 ERROR + 0 MISSING — all four files originally quarantined this session are unblocked.

### Changed

- Grammar pin bumped to `2ffbde9`.

## [1.6.0]

### Fixed

- **Nested `if … then return … / end if / end if` now parses correctly.** A zero-width `inline_marker` external token is required between `then` and the one-liner tail in `if_simple_statement`; the scanner only emits it when the next non-extras character is on the SAME logical line as `then` (either same physical row, or reached through one or more `¬` line-continuation glyphs). A bare newline rejects the marker, forcing the multi-line `if_block` form to be the only viable path. This was the long-standing bug that `prec.dynamic` on `if_block` couldn't recover from — GLR was committing to `if_simple_statement` before reaching the disambiguating `end if`.
- **Tail of `if_simple_statement` widened to any `_item`.** Since the inline_marker constraint guarantees no multi-line if-block body can be misread as a one-liner tail, the tail no longer needs to be one of 5 atomic statements (return/exit/continue/error/log). Idioms like `if cond then ¬\n  tell app to do X` and `if cond then say "yes"` now parse correctly.
- Bonus: `attach_folder_action.applescript` now parses cleanly — was the cascade source for the third quarantined file. Moved to `folder_actions/`. Active corpus is **35/35** with 0 ERROR + 0 MISSING. Only **one** file remains in `known-limits/` (`remove_folder_actions.applescript` — hits rule-level cross-newline `compound_name` extension, documented inline).

### Changed

- Grammar pin bumped to `34a26d0`.
- `known-limits/README.md`: one file remaining (was 2); `attach_folder_action.applescript` listed under "Resolved".

### Not fixed in this release

- `remove_folder_actions.applescript` still has 3 ERROR nodes. The root cause is rule-level cross-newline `compound_name` extension: after `tell app "Sys" to ¬\n  delete folder action X` followed by `end if` on the next line, the parser's rule-level `extras` skip the newline before the next `compound_name` continuation, so `end repeat` / `end if` tokens get pulled into a multi-line `compound_name`. The fix needs a row-tracking external token inside `compound_name`'s rule continuation, not just inside multi-word tokens.

## [1.5.0]

### Fixed

- **Multi-word grammar tokens no longer glue across newlines.** Every `/\s+/` inside a `token(...)` definition was matching newlines, so multi-word names (`default answer`, `with multiple selections allowed`, `path to home folder`, `adding folder items to`, etc.) greedily stitched the next indented line into the current statement. Replaced 133 occurrences with `/[ \t]+/`. Tokens are now bounded to a single physical line.
- Bonus: `test/corpus/realworld/known-limits/comment_tags.applescript` now parses cleanly (was previously 2 ERRORs from a post-block-comment cascade rooted in this same gluing). Moved to `edge_cases/`. Active corpus is **34/34** with 0 ERROR + 0 MISSING.

### Changed

- Grammar pin bumped to `c20c217` (first 7 chars of new pin).
- `known-limits/README.md`: 2 files remaining (was 3); `comment_tags.applescript` listed under "Resolved".

### Known trade-off

- Multi-word names split with the line-continuation glyph `¬` *inside the name itself* (e.g. `default ¬\n   answer` as a single `parameter_name`) will no longer match. Users typically place `¬` between higher-level constructs (between parameters, not inside a multi-word parameter name), so this case is extremely rare. If it ever surfaces in real corpus, the fix is to widen the in-token whitespace class to `[ \t¬]+`.

### Not fixed in this release

- Rule-level cross-newline attach of `command_parameter` (e.g. `display dialog "X"\n    default answer ""` still binds the second line back as a parameter). This is a separate concern from the token gluing and is documented inline in `grammar.js` above the `command_parameter` rule.
- Two files remain in `known-limits/` (`attach_folder_action.applescript`, `remove_folder_actions.applescript`) — both hit the outer-`if`-block-terminator cascade, which is unrelated to multi-word token gluing.

## [1.4.0]

### Added

- **Context-sensitive `to` (column-aware external token)**: `keyword_handler_to` now only fires at column 0, so `move X to Y` and `from N to M` mid-statement no longer get mis-parsed as handler headers. First use of `lexer->get_column` in the scanner; lays the groundwork for further column-aware tokens in Phase 3.

### Fixed

- `test/corpus/realworld/object_specifiers/colorsync_extract.applescript` now parses cleanly (was previously quarantined in `known-limits/` due to this exact `to` ambiguity). Active corpus is 33/33 with zero ERROR + zero MISSING.

### Changed

- Grammar pin bumped to `1d6f1af` (column-aware `keyword_handler_to`).
- `known-limits/README.md` updated: 3 files remaining (was 4); colorsync_extract listed under a new "Resolved" section.

## [1.3.0]

### Added

- **Pipe-delimited identifiers** (`|name with spaces|`): an external scanner token recognises the AppleScript form for identifiers containing spaces, apostrophes, or words that would otherwise look reserved (`|class|`, `|set|`). Accepted everywhere an identifier slot exists — as an expression, as set/copy targets, in parameter lists, property declarations, global/local declarations, error parameter clauses, and compound names. Handler names intentionally stay plain.
- `highlights.scm` captures `(piped_identifier)` as `@variable` so piped identifiers get the same color as plain ones.

### Changed

- Grammar pin bumped to `10d0c9e` (piped identifiers external scanner token). 89/89 fixture tests pass.

## [1.2.0]

### Added

- **`continue <command>` delegation** — `continue_statement` now accepts an optional `command_call`, supporting the parent-handler delegation idiom (`on activate / continue activate / end activate`).
- **`idle` handler** — already parsed as a regular handler; added a corpus fixture so the `on idle / return N / end idle` shape is locked.
- **JXA injection** — `run script "…"` now injects `javascript` when the string body has JS-shaped tokens (`function`, `var`/`let`/`const`, `=>`, `//`, `Application(`), and `applescript` otherwise. The two injection rules use opposing `#match?` / `#not-match?` predicates so each string body matches exactly one.

### Fixed

- Cleared remaining `MISSING keyword_end` in `with_clauses.applescript`. The active real-world corpus now parses with **zero ERROR + zero MISSING** (32/32 active files; 4 files remain documented in `known-limits/`).
- Removed stray duplicate `grammars/applescript` gitlink that had no `.gitmodules` mapping (`git submodule status` was failing as a result).

### Changed

- `extension.toml` grammar pin bumped to `cdbdc1c` (continue + idle + corpus). 86/86 fixture tests pass.
- Documented the known one-liner gap (`if cond then <command_call>` parses as `if_block` with synthesized `end`) in `test/corpus/realworld/known-limits/README.md`.
- `tree-sitter-applescript-old/` removed from the working tree; `AGENTS.md` is now a symlink to `CLAUDE.md`.
- Roadmap rewritten to reflect maintenance mode (further parser work is demand-driven).

## [1.1.2] - 2026-05-19

### Changed

- Grammar pin bumped to `160e21b`: quarantined four real-world files into `test/corpus/realworld/known-limits/` (parser limitations needing column-aware external-scanner work). Active corpus is 32/32 with 0 ERROR.

## [1.1.1] - 2026-05-19

### Added

- **Grammar coverage**: possessive `'s`, ObjC selector calls (`receiver's selector:arg …`), `a reference to <expr>`, date literals, `make new <element>`, `whose`/`where` filter clauses, line continuation `¬` as whitespace, ObjC-style handler definitions (`on splitString:s byDelim:d`), `«data utxt201C»` raw data literals, `my <expr>` self-reference, postfix `exists` predicate, `with transaction` block, `but ignoring` / `but considering` clauses, `numeric strings` / `expansion` text attributes, AppleScript built-in constants (`pi`, `space`, `tab`, `linefeed`, `quote`, weekdays, months, time units), `current_date` as an expression atom, ordinal-suffix numbers (`1st`, `2nd`), `its` reference, relative reference forms (`before`, `after`, `behind`, `in front of`, `in back of`), full operator-synonym table.
- **`use` statement extensions**: alias binding (`use Safari: application "Safari"`), `version "X"` clause, `with importing` / `without importing`, `use script "Library"`.
- **External scanner** (`src/scanner.c`): quote-aware block comments (`(* "*)" *)` no longer closes early); context-sensitive `alias` (distinguishes `alias "X"` prefix from `alias of theItem` property).
- **Language injections**: bash highlighting inside `do shell script "…"`; recursive AppleScript inside `run script "…"`.
- **Shebang detection** (`#!/usr/bin/osascript`) via `first_line_pattern`.
- **Explicit auto-close pairs** for `()`, `{}`, `(* *)`, `""` in `config.toml`.
- **Per-handler gutter "run"** actually invokes that handler (was previously re-running the whole file). Only zero-arg handlers are supported (the runner appends `"$ZED_SYMBOL"()` to a temp copy and runs `osascript` over it).
- **36-file real-world corpus** at `grammars/tree-sitter-applescript/test/corpus/realworld/`, drawn from Apple's `/Library/Scripts/` and hand-crafted ASObjC samples. Used as a regression target. From 732 ERROR nodes at start down to a clean active set (32/32 active files at 0 ERROR; 4 documented in `known-limits/`).
- **`docs/references/`** caches Apple's AppleScript Language Guide, the tree-sitter authoring docs, the Zed extension docs, and the tree-sitter external-scanner reference so future grammar work doesn't need to round-trip through the web.

### Changed

- `highlights.scm` covers every new grammar node (possessive accessor, ObjC selector calls, date literals, `new` specifier, `whose` clause, `applescript_constant`, `its_reference`, raw data, etc.).
- `outline.scm` lists `use` imports alongside handlers, scripts, and properties.

## [1.0.0] - 2025-12-31

### Added

- Initial release
- Tree-sitter grammar for AppleScript (token-based for reliable highlighting)
- Syntax highlighting for keywords, strings, numbers, operators
- Support for `.applescript` and `.scpt` file extensions
- Line comments (`--`) and block comments (`(* *)`)
- Case-insensitive keyword matching
