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
| Run individual handler | ⚠️ | Gutter run button per handler — invokes the handler by appending `<handler>()` to a temp copy of the file. **Zero-arg handlers only.** The top-level script body still runs before the appended call. |
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

**Current state:** **34 of 34 active corpus files parse with zero `ERROR` and zero `MISSING` nodes.** Total reduction from baseline: **732 → 0 ERRORs across the active corpus**.

Two files exhibit known parser limitations and are quarantined under [`test/corpus/realworld/known-limits/`](https://github.com/HelgeSverre/tree-sitter-applescript/tree/main/test/corpus/realworld/known-limits) with a per-file explanation in [`known-limits/README.md`](https://github.com/HelgeSverre/tree-sitter-applescript/blob/main/test/corpus/realworld/known-limits/README.md). They stay in the repo as regression targets for the future scanner-architecture work that would un-block them — they are not deleted, just excluded from the green-build measurement until the underlying grammar can handle their specific edge cases.

### External scanner

[`src/scanner.c`](https://github.com/HelgeSverre/tree-sitter-applescript/blob/main/src/scanner.c) is a hand-written C scanner that implements two context-sensitive tokens tree-sitter's pure-grammar lexer can't represent:

- **`block_comment`** — `(* ... *)` that respects strings and nests. The regex-based comment closed at the first `*)` even when it was inside a `"..."` string; the scanner tracks quote state and depth.
- **`alias_prefix`** — emits `alias` only when the next non-whitespace input isn't `of`. This separates `alias <expr>` (a value-creating prefix, used by `copy alias "X" to y`) from `alias of theItem` (still a plain property reference).

### Why the two files are quarantined

Each documents a distinct precedence or context-sensitivity limit. Summarised in `known-limits/README.md`:

- **Outer `if_block` terminator** (`attach_folder_action`, `remove_folder_actions`) — `end if` where the `if` could be the optional handler-name or a fresh `keyword_if`; tree-sitter's GLR picks the wrong one.

Note: `colorsync_extract.applescript` was unblocked in v1.4.0 by the column-aware `keyword_handler_to` scanner token. `comment_tags.applescript` was unblocked in v1.5.0 when multi-word tokens were bounded to a single physical line. Both are now in the active corpus.

The remaining two issues need further column-/position-aware external scanner work — documented in [`docs/references/external-scanner/02-lessons-learned.md`](docs/references/external-scanner/02-lessons-learned.md).

## Known limitations

After a complete audit against Apple's [AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html), the following constructs are documented language features the grammar does **not** yet model.

### Tractable (purely additive, no scanner work needed)

- **`idle` handler return-interval semantics** (`on idle … return N … end idle`) — parses as a regular handler; the contract that the return value is the next-wake interval isn't surfaced structurally.
- **`continuing <command>` flow** — `continue <command_call>` parses as a `continue_statement` but the command body that follows isn't bound into it.
- **Deprecated keywords** `returning` (alt for `to` in handler defs) and `put` / `put into` (alt for `copy`). Skipped because they're rare and would risk grammar churn for no real-world benefit.

### Needs an external C scanner (substantial)

- **Pipe-delimited identifiers** (`|My Identifier|`) — resolved in v1.3.0; listed here for historical reference only.
- **Multi-line `compound_name` cascade** — `command_parameter`'s `compound_name` value greedily spans newlines into the next statement. Documented above under "Real-world coverage".

### Intentionally not modeled

- **AppleScript Studio** (deprecated since 2011, removed from Xcode) — `on clicked theObject`, `tell window "Main"`, `call method ... of class ...`. Some legacy scripts still use it; we don't.
- **Smart curly quotes inside source** (`"…"` vs `"…"`) — `osadecompile` always emits straight quotes; documented as accept-on-demand.
- **`.scptd` script bundles** — these are macOS packages, not files; Zed opens them as folders.
- **Multi-word application-dictionary constants we haven't whitelisted** — e.g. `Eight channel`, `RGB`, `CMYK` inside `using terms from`. These parse as separate identifiers (visually correct enough for highlighting); the only way to make tree-sitter resolve them to single constants is to embed every app's `.sdef` dictionary into the grammar, which isn't practical.

## Roadmap

**Status: maintenance mode as of v1.5.0.** All editor surfaces are wired, the active 34-file real-world corpus parses with 0 ERROR + 0 MISSING, and the remaining items below all require further column-aware external scanner work. AppleScript itself is in long-term decline (Apple archived the Language Guide; AS Studio was deprecated in 2011), so new investment here is demand-driven, not roadmap-driven.

### Done

- **Quick wins**: `with transaction`, `numeric strings` / `expansion` attributes, `but considering` / `but ignoring`, AppleScript constants (`pi`, `space`, `tab`, `linefeed`, `quote`), weekday/month constants, time-unit constants.
- **Operator polish**: full comparison synonym table; short forms `prop`, `ref`.
- **Idiomatic AppleScript**: `its` reference, ordinal-suffix numbers (`1st`, `2nd`, `23rd`).
- **Reference forms**: `before`, `after`, `behind`, `in front of`, `in back of`.
- **`use` statement extensions**: aliased binding, `version` clause, `with importing` / `without importing`, `use script "X"`.
- **External scanner** (`src/scanner.c`): quote-aware block comments; context-sensitive `alias` keyword.
- **v1.2 additions**: `idle` handler (corpus-locked); `continue <command>` delegation; JXA detection in `run script "…"` injections (switches injected language between `applescript` and `javascript` based on JS-shaped tokens in the string body).
- **v1.3.0 addition**: pipe-delimited identifiers (`|name with spaces|`) — external scanner token, accepted everywhere an identifier slot exists.
- **v1.4.0 addition**: context-sensitive `to` — column-aware external token; `move X to Y` and `from N to M` no longer mis-parse as handler headers. Unblocked `colorsync_extract.applescript` (now in the active corpus).
- **v1.5.0 addition**: multi-word grammar tokens (`default answer`, `with multiple selections allowed`, etc.) are now bounded to a single physical line — eliminates an entire class of cross-line gluing bugs. Unblocked `comment_tags.applescript` (now in the active corpus); `known-limits/` is down to 2 files.

### Deferred — needs external-scanner work, not LLM-driven

This shares the column-aware-scanner primitive already introduced in v1.4.0; landing further work here would unlock the remaining two files in `test/corpus/realworld/known-limits/` and (if anyone still cares) AppleScript Studio support.

### Out of scope

- **Language-server features** (completion, hover, go-to-def, diagnostics, rename, formatting) — no maintained AppleScript LSP exists.
- **Debugger (DAP)** — no AppleScript debugger exists outside Script Editor / Script Debugger.
- **AppleScript Studio** — deprecated by Apple in 2011, removed from Xcode; no realistic user base.
- **`.scptd` script bundles** — macOS packages, not files; Zed opens them as folders.
- **JavaScript for Automation (JXA) as its own language** — would need a separate grammar.
- **`if cond then <command_call>` one-liner** — known parser gap; supported one-line tails are `return`, `exit`, `continue`, `error`, `log`. Use the block form (`if cond then\n  command\nend if`) for command calls.

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
