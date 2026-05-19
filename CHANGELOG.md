# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
