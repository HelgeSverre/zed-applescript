# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Real-world AppleScript coverage: grammar pin bumped to cover possessive `'s`, ObjC selector calls (`receiver's selector:arg …`), `a reference to <expr>`, date literals, `make new <element>`, `whose`/`where` filter clauses, line-continuation `¬` as whitespace, additional text comparison operators.
- Language injections: bash highlighting inside `do shell script "…"`; AppleScript inside `run script "…"`.
- Shebang detection (`#!/usr/bin/osascript`) via `first_line_pattern`.
- Explicit auto-close pairs for `()`, `{}`, `(* *)`, `""` in `config.toml`.
- Per-handler gutter "run" actually invokes that handler (was previously re-running the whole file).

### Changed

- Highlight rules extended to cover new grammar nodes (possessive accessor, ObjC selector calls, date literals, `new` specifier, `whose` clause).
- Outline now lists `use` imports alongside handlers, scripts, and properties.

## [1.0.0] - 2025-12-31

### Added

- Initial release
- Tree-sitter grammar for AppleScript (token-based for reliable highlighting)
- Syntax highlighting for keywords, strings, numbers, operators
- Support for `.applescript` and `.scpt` file extensions
- Line comments (`--`) and block comments (`(* *)`)
- Case-insensitive keyword matching
