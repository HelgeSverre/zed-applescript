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

**Current state:** 32 of 36 files parse with zero `ERROR` nodes (98.2% error reduction from baseline). The remaining 13 errors cluster in four files and are caused by three issues that need an external scanner to fix cleanly:

- The block-comment regex (`(* … *)`) can't recognize that `"*)"` inside a string is part of the string, not the comment terminator. Affects `comment_tags.applescript`.
- The `alias` keyword has dual roles — prefix (`copy alias "X" to y`) and property (`alias of theItem`) — that GLR can't disambiguate without context. Affects `attach_folder_action.applescript` lines using `copy alias ((…))`.
- Multi-line `repeat` / `try` bodies where `to <ident>` could be either a command parameter or a handler-definition start. Affects `colorsync_extract.applescript` and `remove_folder_actions.applescript`.

These don't affect highlighting outside the specific cascading line.

## Known limitations

These are language constructs the grammar does not yet model, based on a complete pass through Apple's [AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html). Most are uncommon in real code; the impact today is that they parse as a sequence of separate identifiers rather than a single structured node, which means highlighting is "OK but not great" rather than wrong.

### Block-level constructs

- **`with transaction [<session>] … end transaction`** — used to bundle multiple Apple events as one atomic operation. Currently parses as `with` + identifier + body, not as a transaction block.
- **`but ignoring …` / `but considering …` modifier** inside `considering` / `ignoring` blocks. Example: `considering case but ignoring white space`. The `but` clause is dropped.
- **`numeric strings`** and **`expansion`** text attributes inside `considering` / `ignoring`. Useful: `considering numeric strings` enables version-string comparison.
- **`idle` handler** (`on idle … end idle` returning an interval) — parses as a regular handler, no special semantics, but the return-an-interval contract is invisible to the grammar.

### Reference & operator forms

- **Pipe-delimited identifiers** (`|My Identifier|`) — AppleScript's escape syntax for identifiers with spaces or reserved-word collisions. Currently the `|` characters break the parse.
- **Relative reference forms** `before` / `after` / `in front of` / `in back of` / `behind` as binary operators on element refs (e.g., `word before word 2`). Currently `before` is parsed as an `element_type`.
- **`its` reference** — like `it` but used in property chains (`its name`). Currently parses as a plain identifier.
- **Ordinal-suffix numbers** `1st`, `2nd`, `3rd`, `11th` — equivalent to `first`, `second`, etc. Currently parses as `number + identifier`.

### Date/time arithmetic and constants

- **Time-unit constants** `seconds`, `minutes`, `hours`, `days`, `weeks` — used in date arithmetic (`current date + 5 * days`). Currently parses as plain identifiers, so the arithmetic structure parses but the units don't highlight as constants.
- **Day-of-week constants** `Monday` through `Sunday` — special enum values. Parse as identifiers.
- **Month constants** `January` through `December` — same.
- **AppleScript built-in constants** `pi`, `space`, `tab`, `return`, `linefeed`, `quote`, `null` — parse as identifiers (semantically a no-op, but they should highlight as `@constant.builtin`).

### Deprecated / short-form keywords

These compile in AppleScript but aren't recognized as keywords:
- **`returning`** — deprecated synonym for `to` in handler definitions
- **`put`** / **`put into`** — deprecated synonym for `copy`
- **`prop`** — short form of `property`
- **`ref`** — short form of `reference`

### Operator synonyms still to surface

The grammar already recognizes the most common forms (`is`, `is not`, `contains`, `starts with`, etc.). Less-common synonyms documented in the language guide but not all wired up:

- `equal` / `equals` / `equal to` / `is equal to` (we have `is equal to`, `equals`)
- `doesn't equal` / `does not equal` / `is not equal` (we have `is not equal to`)
- `doesn't come before` / `doesn't come after` (we have `comes before` / `comes after`)
- `is contained by` / `is not contained by` / `isn't contained by` (we have `contains` / `does not contain`)

### `use` statement extensions

The basic forms work (`use framework "X"`, `use scripting additions`, `use AppleScript version "X"`, `use application "X"`). Less-common variants:

- **Aliased binding**: `use Safari: application "Safari"` — the `name:` aliasing prefix
- **Version + importing clauses**: `use application "X" version "7.0" without importing`
- **Script-library imports**: `use script "My Library"` — currently parses, but no library-specific semantics

### `continuing` clause

A handler can defer to the next handler in the chain with `continue <command>`. The continuation form is parsed as a `continue_statement` but the command body that follows isn't structured as part of it.

### Fundamental tree-sitter limits

Two limitations need an external C scanner to fix, not just grammar rules:

- **Block comments don't recognize strings.** `(* … "*)" … *)` closes the comment at the first `*)` even when it's inside a string literal. The regex-based comment tokenizer can't track quote state.
- **`alias` keyword vs property name ambiguity.** `alias "Path"` (prefix) and `alias of theItem` (property) need context-sensitive lexing to disambiguate. GLR can't do it cleanly without a major restructure.

## Roadmap

In rough priority order (highest impact / lowest effort first):

1. **Quick wins (purely additive, no precedence work):** ✅ done
   - ✅ `with transaction` block
   - ✅ `numeric strings`, `expansion` to `text_attribute`
   - ✅ `but considering` / `but ignoring` clauses
   - ✅ AppleScript built-in constants (`pi`, `space`, `tab`, `linefeed`, `quote`) — `return` excluded to avoid lexer collision with the return statement keyword
   - ✅ Day-of-week (`Monday`–`Sunday`) and month (`January`–`December`) names
   - ✅ Time-unit constants (`seconds`, `minutes`, `hours`, `days`, `weeks`)

2. **Operator polish:** ✅ done
   - ✅ Operator synonyms (`equal`, `equals`, `equal to`, `is equal to`; `isn't equal to`, `does not equal`, `doesn't equal`; `is contained by`, `isn't contained by`; `doesn't come before` / `doesn't come after`; `start with` / `begin with` / `end with` singular)
   - ✅ Deprecated short forms: `prop` (alias for `property`), `ref` (alias for `reference`)
   - ❌ `returning`, `put` — context-specific and rare; skipped to avoid grammar churn

3. **Idiomatic AppleScript:**
   - ✅ `its_reference` as a distinct special reference (separate from `it`)
   - ✅ Ordinal-suffix numbers (`1st`, `2nd`, `23rd`, `101st`)
   - ⏳ `idle` handler with explicit return-interval semantics — parses generically today; specific structure not yet modeled

4. **Reference forms:**
   - ✅ Relative reference forms (`before`, `after`, `behind`, `in front of`, `in back of`) as expression atoms — parses cleanly in expression position; binding into command parameters still subject to the `to`/handler-def ambiguity from item 7
   - ⏳ Pipe-delimited identifiers (`|name with spaces|`) — needs a new token rule

5. **`use` statement extensions:** ✅ done
   - ✅ Aliased binding (`use Safari: application "Safari"`)
   - ✅ `version "X"` clause
   - ✅ `with importing` / `without importing` clauses
   - ✅ `use script "Library"` form

6. **`continuing` flow:**
   - ⏳ `continue <command_call>` as a structured statement (currently parses as `continue_statement` + orphan command tokens)

7. **External scanner (large project, defers indefinitely):**
   - Quote-aware block comments — affects `comment_tags.applescript`
   - Context-sensitive `alias` keyword — affects `attach_folder_action.applescript`
   - Context-sensitive `to` (`move X to Y` vs `to handlerName()`) — affects `colorsync_extract.applescript` and `remove_folder_actions.applescript`
   - Would also enable AppleScript Studio support (`on clicked theObject`, `tell window "Main"`) and JXA detection in `run script "…"` injections

8. **Intentionally out of scope:**
   - **Language server features** (completion, hover, go-to-def, diagnostics, rename, formatting) — no maintained AppleScript LSP exists; building one from scratch is its own multi-month project.
   - **Debugger (DAP)** — no AppleScript debugger exists outside Script Editor / Script Debugger.
   - **`.scptd` script bundles** — these are macOS packages, not files; Zed opens them as folders.
   - **JavaScript for Automation (JXA)** — a separate language that targets the same Apple-event APIs; would need its own grammar.

For anyone picking up the remaining items, [`docs/references/`](docs/references/) caches the authoritative documentation (Apple Language Guide, tree-sitter authoring docs, Zed extension docs, external-scanner reference) so the next change can be made without round-tripping through the web.

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
