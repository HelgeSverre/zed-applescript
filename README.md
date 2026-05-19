# AppleScript for Zed

AppleScript language support for the [Zed](https://zed.dev) editor.

## Features

- Syntax highlighting for AppleScript
- Support for `.applescript` and `.scpt` file extensions
- Line comments (`--`) and block comments (`(* *)`)
- Auto-indentation for block structures
- Code outline showing handlers, properties, and tell blocks
- Bracket matching
- Vim-style text objects
- Run scripts directly from the editor via `osascript`

## Support matrix

### Editor / structural features

| Feature | Status | Notes |
| --- | --- | --- |
| Syntax highlighting | ✅ | `languages/applescript/highlights.scm` — comments, strings, numbers, booleans, operators, type specifiers, command names, parameter names, handler/script names, control-flow keywords |
| Comments — line (`--`, `#`) | ✅ | `config.toml` |
| Comments — block (`(* *)`) | ✅ | `config.toml` |
| Auto-indentation | ✅ | Increases inside handlers, `tell`, `if`, `repeat`, `try`, `considering`, `ignoring`, `with timeout`, `using terms from`, `script` blocks; outdents on `end` |
| Bracket matching | ✅ | `()`, `{}` for parameter lists, parenthesized expressions, lists, records |
| Code outline | ✅ | Handlers (with parameters), `script` objects, properties, `tell` block targets |
| Vim text objects | ✅ | `@function` (handlers, `tell`, `if`, `repeat`, `try`, etc.), `@class` (script objects), `@comment` |
| Run script (whole file) | ✅ | Gutter run button → `osascript $ZED_FILE` |
| Run individual handler | ✅ | Gutter run button per handler — invokes just the handler by appending `<handler>()` to the file content in a temp script |
| Auto-closing brackets / quotes | ✅ | `()`, `{}`, `(* *)`, `""` auto-close via `config.toml` brackets array |
| Shebang detection (`#!/usr/bin/osascript`) | ✅ | `first_line_pattern` in `config.toml` |
| Language injections | ✅ | Bash highlighting inside `do shell script "…"`; recursive AppleScript inside `run script "…"` |
| Snippets | ❌ | None shipped |

### Grammar coverage

Provided by the [tree-sitter-applescript](https://github.com/HelgeSverre/tree-sitter-applescript) grammar pinned in `extension.toml`.

| Construct | Status |
| --- | --- |
| Handlers — `on` / `to`, positional params, labeled (`given …:`) params | ✅ |
| Tell blocks — block form (`tell … end tell`) and one-line form | ✅ |
| Conditionals — `if`/`then`/`else if`/`else` block and one-line `if … then …` | ✅ |
| Loops — all `repeat` forms | ✅ |
| Error handling — `try` / `on error` with error parameter clauses | ✅ |
| Scoping blocks — `considering`, `ignoring`, `with timeout`, `using terms from` | ✅ |
| Declarations — `property`, `global`, `local`, `set`, `copy` | ✅ |
| Script objects — `script` … `end script` with `parent` clause | ✅ |
| `use` statements — application / framework / scripting additions / version | ✅ |
| Commands — `command_name`, named parameters, `given` clause | ✅ |
| Object specifiers — `element_type`, `specifier_prefix`, references, indexing, ranges | ✅ |
| Object specifier filter — `whose` / `where` clauses | ✅ |
| Literals — string + escape sequences, number, boolean, list, record, `missing value`, `null`, date literal | ✅ |
| Special references — `me`, `it`, `result`, `current application` | ✅ |
| Possessive `'s` — `current application's NSString`, chained `x's y's z` | ✅ |
| `a reference to <expr>` — common ASObjC idiom | ✅ |
| ObjC bridge — `receiver's selector:arg [label:arg …]` method-call syntax | ✅ |
| `make new <element_type> …` argument form | ✅ |
| Line continuation `¬` — consumed as whitespace, parses join transparently | ✅ |
| Coercion — `value as type` | ✅ |
| Operators — comparison (`begins/ends/starts with`, `contains`, `is in`, …), logical, arithmetic, unary, range, concatenation | ✅ |
| Text attributes — `case`, `diacriticals`, etc. (inside `considering` / `ignoring`) | ✅ |
| `log`, `return`, `error`, `exit`, `continue` statements | ✅ |
| Decorative `the` (`set the x to the name of the file`) | ✅ |
| `current date` / `current application` builtins | ✅ |
| Implicit `on run` script (top-level `end run` matches) | ✅ |
| `my <handler>(…)` self-reference and handler calls | ✅ |
| Multi-word application-dictionary identifiers (`current view`, `name extension`, `text item delimiters`, `application file`, `static text`, …) | ✅ Handled via `compound_name` (1–3 word names) and a small built-in vocabulary of multi-word `element_type`s. Tree-sitter has no `.sdef` access, so an unknown 4+ word app constant may still split into separate identifiers in highlighting. |
| ObjC-style handler definitions (`on selector:arg [label:arg …] … end selector:label:`) | ✅ |
| Folder Action handler shapes (`on adding folder items to fld after receiving items`, `on opening folder`, etc.) | ✅ |
| AppleScript raw-data literals (`«class fold»`, `«data utxt201C»`) | ✅ |

### Code intelligence (LSP-backed)

There is no maintained AppleScript language server, so none of these features are available and there are no concrete plans to add them. Listed for completeness.

| Feature | Status |
| --- | --- |
| Completion / IntelliSense | ❌ |
| Hover documentation | ❌ |
| Go to definition / find references | ❌ |
| Rename symbol | ❌ |
| Diagnostics / linting | ❌ |
| Code actions / quick fixes | ❌ |
| Formatter | ❌ (no AppleScript formatter exists) |
| Debugger (DAP) | ❌ |

### File handling

| Feature | Status | Notes |
| --- | --- | --- |
| `.applescript` files | ✅ | |
| `.scpt` files | ✅ | Listed as a suffix; note these are usually compiled binaries and won't render as readable text |
| `.scptd` script bundles | ❌ | `.scptd` is a package directory, not a file — Zed opens these as folders, not editable scripts |

### Real-world coverage

The grammar is exercised against a corpus of real AppleScript files under [`grammars/tree-sitter-applescript/test/corpus/realworld/`](https://github.com/HelgeSverre/tree-sitter-applescript/tree/main/test/corpus/realworld) — 36 scripts drawn from Apple's `/Library/Scripts/`, decompiled `.scpt` Folder Actions and Printing Scripts, plus hand-crafted ASObjC and edge-case samples. A categorized gap analysis lives in [`ERRORS.md`](https://github.com/HelgeSverre/tree-sitter-applescript/blob/main/test/corpus/realworld/ERRORS.md) for anyone extending the grammar.

## Installation

1. Open Zed
2. Open the command palette (`Cmd+Shift+P`)
3. Search for "zed: extensions"
4. Search for "AppleScript" and click Install

## Supported Syntax

- **Handlers**: `on`/`to` ... `end`
- **Tell blocks**: `tell application` ... `end tell`
- **Control flow**: `if`/`then`/`else`, `repeat`, `try`/`on error`
- **Blocks**: `considering`, `ignoring`, `with timeout`, `with transaction`, `using terms from`
- **Declarations**: `property`, `set`, `local`, `global`
- **Use statements**: `use application`, `use framework`, `use scripting additions`

## Example

```applescript
use AppleScript version "2.4"
use scripting additions

property greeting : "Hello"

on sayHello(name)
    tell application "System Events"
        display dialog greeting & ", " & name & "!"
    end tell
end sayHello

sayHello("World")
```

## Development

To test locally:

1. Clone this repository
2. Open Zed
3. Run "zed: install dev extension" from the command palette
4. Select the cloned directory

> [!TIP]
> In the Finder dialog, press `Cmd+Shift+G` to open "Go to Folder" and paste a path directly.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details.
