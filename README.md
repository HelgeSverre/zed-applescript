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

**Current state:** 32 of 36 files parse with zero `ERROR` nodes (**98.6% error reduction from baseline**, down from 732 ERROR nodes on day one to 10 today). The remaining 10 errors cluster in four files.

### External scanner

[`src/scanner.c`](https://github.com/HelgeSverre/tree-sitter-applescript/blob/main/src/scanner.c) is a hand-written C scanner that implements two context-sensitive tokens tree-sitter's pure-grammar lexer can't represent:

- **`block_comment`** — `(* ... *)` that respects strings and nests. The regex-based comment closed at the first `*)` even when it was inside a `"..."` string; the scanner tracks quote state and depth.
- **`alias_prefix`** — emits `alias` only when the next non-whitespace input isn't `of`. This separates `alias <expr>` (a value-creating prefix, used by `copy alias "X" to y`) from `alias of theItem` (still a plain property reference).

### Remaining 10 errors

Concentrated in four files, all caused by `command_parameter`'s `compound_name` value greedily spanning newlines into the next statement. Specifically, `with multiple selections allowed` parses as bare `with` + a value that then absorbs the next line's `if class of …` because AppleScript has no statement terminator and tree-sitter has no line-aware grammar primitives.

**Attempted fix that didn't work:** a third external token (`compound_word`) that would match an identifier only when not a reserved keyword. Left in the git history (commit `5d907bf`) for anyone who wants to revisit. The trouble: too many keyword-like words (`down`, `option`, `up`, `front`, `back`) are valid property names in macOS app dictionaries — restricting them broke far more parses than it fixed.

A real fix needs context-sensitive disambiguation of which `with X Y Z` patterns are single multi-word parameter names vs. `with <flag> <value>`. That requires either threading line/position state through the scanner or extending the parameter-name vocabulary to cover every documented Standard Additions parameter — both substantially more work than the rest of the roadmap combined.

These don't affect highlighting outside the specific cascading line.

## Known limitations

After a complete audit against Apple's [AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html), the following constructs are documented language features the grammar does **not** yet model.

### Tractable (purely additive, no scanner work needed)

- **`idle` handler return-interval semantics** (`on idle … return N … end idle`) — parses as a regular handler; the contract that the return value is the next-wake interval isn't surfaced structurally.
- **`continuing <command>` flow** — `continue <command_call>` parses as a `continue_statement` but the command body that follows isn't bound into it.
- **Deprecated keywords** `returning` (alt for `to` in handler defs) and `put` / `put into` (alt for `copy`). Skipped because they're rare and would risk grammar churn for no real-world benefit.

### Needs an external C scanner (substantial)

- **Pipe-delimited identifiers** (`|My Identifier|`) — AppleScript's escape syntax for identifiers with spaces or reserved-word collisions. Currently the `|` characters break the parse.
- **Multi-line `compound_name` cascade** — `command_parameter`'s `compound_name` value greedily spans newlines into the next statement (the cause of the 10 remaining corpus errors). Documented above under "Real-world coverage".
- **`to <ident>` ambiguity** inside expression bodies — `move X to trash` vs `to handlerName()`. GLR keeps both alive and picks handler-def in cascade cases. Would need a column-aware scanner.

### Intentionally not modeled

- **AppleScript Studio** (deprecated since 2011, removed from Xcode) — `on clicked theObject`, `tell window "Main"`, `call method ... of class ...`. Some legacy scripts still use it; we don't.
- **Smart curly quotes inside source** (`"…"` vs `"…"`) — `osadecompile` always emits straight quotes; documented as accept-on-demand.
- **`.scptd` script bundles** — these are macOS packages, not files; Zed opens them as folders.
- **Multi-word application-dictionary constants we haven't whitelisted** — e.g. `Eight channel`, `RGB`, `CMYK` inside `using terms from`. These parse as separate identifiers (visually correct enough for highlighting); the only way to make tree-sitter resolve them to single constants is to embed every app's `.sdef` dictionary into the grammar, which isn't practical.

## Roadmap

Tracked in rough priority order. Items 1–5 below have all landed; items 6–7 are what's left.

1. **Quick wins** ✅
   - `with transaction` block
   - `numeric strings`, `expansion` text attributes
   - `but considering` / `but ignoring` clauses
   - AppleScript built-in constants (`pi`, `space`, `tab`, `linefeed`, `quote`)
   - Day-of-week + month constants, time-unit constants (`seconds`–`weeks`)

2. **Operator polish** ✅
   - Full comparison synonym table from the Language Guide
   - Short forms `prop`, `ref`

3. **Idiomatic AppleScript** ✅ (partial)
   - `its_reference` as a distinct reference
   - Ordinal-suffix numbers (`1st`, `2nd`, `23rd`)
   - ⏳ `idle` handler with explicit return-interval semantics

4. **Reference forms** ✅ (partial)
   - Relative reference forms (`before`, `after`, `behind`, `in front of`, `in back of`)
   - ⏳ Pipe-delimited identifiers (`|name with spaces|`) — needs an external scanner token

5. **`use` statement extensions** ✅
   - Aliased binding, `version` clause, `with importing` / `without importing`, `use script "X"`

6. **`continuing` flow** ⏳
   - `continue <command_call>` as a structured statement

7. **External scanner** ✅ (partial — see `src/scanner.c`)
   - ✅ Quote-aware block comments (fixed 3 corpus errors)
   - ✅ Context-sensitive `alias` keyword (fixed 2 corpus errors)
   - ⏳ Multi-line `compound_name` cascade — needs more design work; one prototype (commit `5d907bf`) didn't work
   - ⏳ Context-sensitive `to` ambiguity — same family
   - ⏳ Pipe-delimited identifiers
   - Would also enable AppleScript Studio support (`on clicked theObject`) and JXA detection in `run script "…"` injections

8. **Intentionally out of scope**
   - **Language server features** (completion, hover, go-to-def, diagnostics, rename, formatting) — no maintained AppleScript LSP exists.
   - **Debugger (DAP)** — no AppleScript debugger exists outside Script Editor / Script Debugger.
   - **`.scptd` script bundles** — macOS packages, not files; Zed opens them as folders.
   - **JavaScript for Automation (JXA)** — a separate language; would need its own grammar.

[`docs/references/`](docs/references/) caches all the authoritative source material (Apple Language Guide, tree-sitter authoring docs, Zed extension docs, external-scanner reference, [`docs/references/external-scanner/01-scanner-c.md`](docs/references/external-scanner/01-scanner-c.md) for the C-side TSLexer interface) so any future contributor can extend the grammar without round-tripping through the web.

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
