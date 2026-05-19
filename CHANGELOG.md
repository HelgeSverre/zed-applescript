# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Grammar coverage**: possessive `'s`, ObjC selector calls (`receiver's selector:arg …`), `a reference to <expr>`, date literals, `make new <element>`, `whose`/`where` filter clauses, line continuation `¬` as whitespace, ObjC-style handler definitions (`on splitString:s byDelim:d`), `«data utxt201C»` raw data literals, `my <expr>` self-reference, postfix `exists` predicate, `with transaction` block, `but ignoring` / `but considering` clauses, `numeric strings` / `expansion` text attributes, AppleScript built-in constants (`pi`, `space`, `tab`, `linefeed`, `quote`, weekdays, months, time units), `current_date` as an expression atom, ordinal-suffix numbers (`1st`, `2nd`), `its` reference, relative reference forms (`before`, `after`, `behind`, `in front of`, `in back of`), full operator-synonym table.
- **`use` statement extensions**: alias binding (`use Safari: application "Safari"`), `version "X"` clause, `with importing` / `without importing`, `use script "Library"`.
- **External scanner** (`src/scanner.c`): quote-aware block comments (`(* "*)" *)` no longer closes early); context-sensitive `alias` (distinguishes `alias "X"` prefix from `alias of theItem` property).
- **Language injections**: bash highlighting inside `do shell script "…"`; recursive AppleScript inside `run script "…"`.
- **Shebang detection** (`#!/usr/bin/osascript`) via `first_line_pattern`.
- **Explicit auto-close pairs** for `()`, `{}`, `(* *)`, `""` in `config.toml`.
- **Per-handler gutter "run"** actually invokes that handler (was previously re-running the whole file).
- **36-file real-world corpus** at `grammars/tree-sitter-applescript/test/corpus/realworld/`, drawn from Apple's `/Library/Scripts/` and hand-crafted ASObjC samples. Used as a regression target. From 732 ERROR nodes at start to **10 ERROR nodes today** (98.6% reduction).
- **`docs/references/`** caches Apple's AppleScript Language Guide, the tree-sitter authoring docs, the Zed extension docs, and the tree-sitter external-scanner reference so future grammar work doesn't need to round-trip through the web.

### Changed

- `highlights.scm` covers every new grammar node (possessive accessor, ObjC selector calls, date literals, `new` specifier, `whose` clause, `applescript_constant`, `its_reference`, raw data, etc.).
- `outline.scm` lists `use` imports alongside handlers, scripts, and properties.
- `extension.toml` grammar pin bumped to `5d907bf` (tree-sitter-applescript@main).

## [1.0.0] - 2025-12-31

### Added

- Initial release
- Tree-sitter grammar for AppleScript (token-based for reliable highlighting)
- Syntax highlighting for keywords, strings, numbers, operators
- Support for `.applescript` and `.scpt` file extensions
- Line comments (`--`) and block comments (`(* *)`)
- Case-insensitive keyword matching
