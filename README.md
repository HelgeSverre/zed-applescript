# AppleScript for Zed

[![CI](https://img.shields.io/github/actions/workflow/status/HelgeSverre/zed-applescript/ci.yml?branch=main&logo=github&label=CI)](https://github.com/HelgeSverre/zed-applescript/actions/workflows/ci.yml)
[![Latest version](https://img.shields.io/github/v/tag/HelgeSverre/zed-applescript?label=version)](https://github.com/HelgeSverre/zed-applescript/releases/latest)
[![License](https://img.shields.io/github/license/HelgeSverre/zed-applescript)](LICENSE.md)

AppleScript language support for the [Zed](https://zed.dev) editor.

## Install

From inside Zed: `cmd-shift-P` → `zed: extensions` → search for **AppleScript** → Install.

## Features

- Syntax highlighting (line + block comments, strings, numbers, operators, command names, parameters, handlers, control flow, ObjC-bridge calls, raw-data literals, date literals, …)
- Code outline (handlers, properties, script objects, `tell` targets, `use` imports)
- Auto-indent for every block form (`tell`, `if`, `repeat`, `try`, `considering`, `ignoring`, `with timeout`, `with transaction`, `using terms from`, `script`)
- Bracket matching for `()`, `{}`, `(* *)`, `""`
- Vim text objects — `@function`, `@class`, `@comment` (line and block forms)
- Run scripts from the editor: full-file run, individual handler, or compile to `.scpt`
- Language injection — Bash inside `do shell script "…"`; AppleScript or JavaScript-for-Automation inside `run script "…"` based on content sniffing; AppleScript inside markdown fences
- Shebang detection for `#!/usr/bin/osascript`

## Quick reference

### Editor surface

| Feature | Status | Notes |
| --- | --- | --- |
| Highlights | ✅ | `languages/applescript/highlights.scm` |
| Outline | ✅ | Handlers, `script` objects, properties, `tell` targets, `use` imports |
| Indents | ✅ | Inside every block construct; outdents on `end` |
| Brackets | ✅ | `()`, `{}`; auto-close also for `(* *)` and `""` |
| Text objects | ✅ | Vim-style `gc`, `if`, `ic`, etc. |
| Scope overrides | ✅ | Comments and strings (suppresses autocomplete, etc.) |
| Runnables | ✅ | Run script, compile to `.scpt`, run individual handler (zero-arg only) |
| Injections | ✅ | bash / javascript / applescript inside string literals; markdown fence injection works out of the box |
| Shebang detection | ✅ | `^#!.*\bosascript\b` |
| Code folding for block comments | ⚠️ | Limited — Zed has no extension-side fold-query convention; see `CHANGELOG.md` v1.7.3 |
| Snippets | ❌ | None shipped |
| Language-server features (completion, hover, rename, diagnostics, formatter, debugger) | ❌ | No maintained AppleScript LSP exists |

### Grammar coverage

Provided by [tree-sitter-applescript](https://github.com/HelgeSverre/tree-sitter-applescript), pinned by commit in `extension.toml`.

| Construct | Status |
| --- | --- |
| Handlers — `on` / `to`, positional + labeled (`given …:`) params | ✅ |
| Tell — block form and one-line `tell X to …` | ✅ |
| Conditionals — `if`/`then`/`else if`/`else` and one-line `if … then …` | ✅ |
| Loops — all `repeat` forms | ✅ |
| Error handling — `try` / `on error` with error parameter clauses | ✅ |
| Scoping — `considering`, `ignoring`, `with timeout`, `with transaction`, `using terms from` | ✅ |
| Declarations — `property`, `global`, `local`, `set`, `copy` | ✅ |
| Script objects — `script … end script` with `parent` clause | ✅ |
| `use` — application / framework / scripting additions, with aliases / `version` / `with importing` | ✅ |
| Commands — `command_name`, named parameters, `with`/`without` flags, `given` clause | ✅ |
| Object specifiers — `element_type`, references, indexing, ranges, `whose`/`where` | ✅ |
| Literals — string, number (incl. ordinal `1st`/`2nd`), boolean, list, record, date, `missing value`, raw data `«class fold»` | ✅ |
| Special refs — `me`, `it`, `its`, `result`, `current application`, `my <expr>` | ✅ |
| Possessive `'s` and ObjC bridge — `receiver's selector:arg [label:arg …]` | ✅ |
| Pipe-delimited identifiers — `|name with spaces|` | ✅ |
| Line continuation `¬` | ✅ |
| Coercion (`as type`), operators (full synonym table), text attributes | ✅ |
| Multi-word app-dictionary names — `current view`, `name extension`, `text item delimiters`, etc. | ⚠️ Curated vocabulary + 6-word compound names; truly novel 7+-word app constants may split |
| ObjC-style handler defs (`on selector:arg byLabel:arg`) | ✅ |
| Folder-action handler shapes (`on adding folder items to …`) | ✅ |

### Real-world corpus

The grammar is exercised against [36 real AppleScript files](https://github.com/HelgeSverre/tree-sitter-applescript/tree/main/test/corpus/realworld) drawn from Apple's `/Library/Scripts/`, decompiled folder-action and printing scripts, plus hand-crafted ASObjC and edge-case samples.

**Current state: 36/36 active corpus files parse with zero `ERROR` and zero `MISSING` nodes.** Total reduction from baseline: 732 → 0. The `known-limits/` quarantine directory is empty.

A categorized history of which parser changes unblocked which files lives in [`CHANGELOG.md`](CHANGELOG.md).

## Example

```applescript
use AppleScript version "2.4"
use scripting additions

property greeting : "Hello"

on greet(name)
    return greeting & ", " & name & "!"
end greet

on main()
    tell application "System Events"
        display dialog greet("World")
    end tell
end main

main()
```

More samples in [`example/`](example/) — including a markdown injection smoke-test ([`example/injection.md`](example/injection.md)) and a construct showcase ([`example/showcase.applescript`](example/showcase.applescript)).

## Dev workflow

The extension is declarative — no Rust or WASM — so the dev loop is fast.

```bash
just init       # one-time: pull the grammar submodule
just install    # symlink this dir into Zed's extensions/installed/
just dev        # verify queries, then open Zed in the example/ folder
just verify     # check every .scm node reference resolves against the grammar
just test       # run the grammar's 94-fixture test suite
just release X.Y.Z   # bump version, fast-forward grammar, verify, commit, tag
just push       # push main + tags
```

After `just install`, every change to a `.scm` file is picked up by Zed on the next file reload (or via `cmd-shift-P → zed: rebuild dev extension`). Grammar changes need a `just update-grammar` to advance the pin in `extension.toml`.

For a fresh contributor who'd rather have Zed compile the extension via its own builder (instead of the symlink trick), use `just install-via-ui` for instructions.

## Documentation

- [`CHANGELOG.md`](CHANGELOG.md) — version history and per-release notes.
- [`docs/references/`](docs/references/) — cached upstream documentation (Apple's AppleScript Language Guide, tree-sitter authoring docs, Zed extension docs, external-scanner reference). Useful when extending the grammar.

## Contributing

- [`CLAUDE.md`](CLAUDE.md) — repo-internal contract for AI coding agents (and any human who wants the same context). Covers the release process, what `just update-grammar` actually does, and the grammar ↔ extension coupling. `AGENTS.md` is a symlink to this file so Codex picks it up too.
- The `just` recipes — run `just --list` for the full set, or `just status` for a quick health snapshot (current version, grammar pin, submodule sync state).
