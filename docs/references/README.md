# Reference cache

Curated documentation for the four bodies of knowledge this project sits on top of:

- **`applescript/`** — Apple's archived [AppleScript Language Guide](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html). Definitive but archived (no longer actively maintained by Apple).
- **`tree-sitter/`** — Authoring guide for tree-sitter grammars from [tree-sitter.github.io](https://tree-sitter.github.io/tree-sitter/).
- **`zed-extensions/`** — Zed editor extension authoring docs from [zed.dev/docs](https://zed.dev/docs/) and the [`zed_extension_api`](https://github.com/zed-industries/zed/tree/main/crates/extension_api) crate.
- **`external-scanner/`** — Tree-sitter's C-side scanner interface (`scanner.c`), needed for context-sensitive lexing.

Each folder contains:

- `NN-<topic>.md` files — curated, focused excerpts produced via the Context7 MCP. Concise, with code samples. Start here.
- `<source>.txt` files — full plain-text dumps of upstream HTML pages. Authoritative, dense, includes everything the curated files might have missed.

## Why this cache exists

When extending the grammar (especially the items on the roadmap), it's faster to grep this directory than to round-trip through the web. The cache is small (~10k lines total), versioned, and stable.

If the upstream docs change, refresh:

```bash
# Re-pull from Context7 — see Bash history in docs/refresh-references.md (TODO)
# Or re-fetch upstream HTML pages via:
curl -sL https://tree-sitter.github.io/tree-sitter/creating-parsers/4-external-scanners.html \
  | textutil -convert txt -stdin -output external-scanner/ts-external-scanners.txt
```

## What's covered

### `applescript/` — the language

| File | Source | Covers |
| --- | --- | --- |
| `01-lexical-conventions.md` | Context7 | Identifiers, numbers, strings, comments, pipe-delimited identifiers, continuation `¬`, raw codes |
| `02-reference-forms.md` | Context7 | `whose`/`where`, every/first/last/middle, relative refs (before/after/in front of), ordinals |
| `03-operators.md` | Context7 | Full operator list with synonyms |
| `04-control-statements.md` | Context7 | `if`, `repeat` (all forms), `tell`, `try`, `considering`/`ignoring` (with `but` clauses), `with timeout`, `with transaction`, `using terms from` |
| `05-handlers.md` | Context7 | Handler definitions, all parameter labels, `given` clause, `idle`/`open`/`quit`/`run` |
| `06-script-objects.md` | Context7 | `script ... end script`, inheritance, `parent`, `my`/`me`, delegation |
| `07-classes-and-coercion.md` | Context7 | All built-in types, `as` coercion targets, unit types |
| `08-folder-actions.md` | Context7 | All five folder-action handler signatures |
| `09-use-statement.md` | Context7 | `use AppleScript version`, `use framework`, `use scripting additions`, `use script`, `with importing` |
| `10-constants-and-globals.md` | Context7 | `pi`, `space`, `tab`, `return`, `linefeed`, `quote`; weekdays, months, time units |
| `apple-*.txt` | developer.apple.com | Full plain-text dumps of the corresponding Apple HTML pages |

### `tree-sitter/` — authoring grammars

| File | Source | Covers |
| --- | --- | --- |
| `01-grammar-authoring.md` | Context7 | `grammar.js` DSL: rules, choice, seq, repeat, prec, conflicts, externals, word, extras |
| `02-queries-and-highlights.md` | Context7 | `highlights.scm` syntax, captures, predicates, injections |
| `03-conflicts-and-precedence.md` | Context7 | `prec.left` / `prec.right` / `prec.dynamic`, conflict declarations, GLR behaviour |
| `ts-creating-parsers.txt`, `ts-grammar-dsl.txt`, `ts-using-parsers.txt`, `ts-syntax-highlighting.txt` | tree-sitter.github.io | Full upstream pages |

### `external-scanner/`

The roadmap calls out two limits that need an external C scanner:

1. Quote-aware block comments (`(* "*)" *)`)
2. Context-sensitive `alias` keyword (`alias of x` vs `alias "X"`)

| File | Source | Covers |
| --- | --- | --- |
| `01-scanner-c.md` | Context7 | `TSLexer` interface, `advance`/`lookahead`/`mark_end`/`eof_check`, `serialize`/`deserialize`, `externals` array, `valid_symbols` |
| `ts-external-scanners.txt` | tree-sitter.github.io | Full upstream page |

### `zed-extensions/`

| File | Source | Covers |
| --- | --- | --- |
| `01-language-extensions.md` | Context7 | `extension.toml`, `languages/<lang>/`, all 7 `.scm` query files, `tasks.json`, `config.toml` keys |
| `02-extension-api.md` | Context7 | The `zed_extension_api` crate surface |
| `zed-extensions-overview.txt`, `zed-language-extensions.txt` | zed.dev/docs | Full upstream pages |

## How to use this cache when extending the grammar

For each roadmap item, the relevant references are roughly:

| Roadmap item | Where to look |
| --- | --- |
| New grammar atoms (constants, idle handler, etc.) | `applescript/05-handlers.md`, `10-constants-and-globals.md`; `tree-sitter/01-grammar-authoring.md` |
| Reference-form operators (`before`, `after`, `in front of`) | `applescript/02-reference-forms.md`, `apple-reference-forms.txt` |
| Operator synonyms | `applescript/03-operators.md` |
| `use` statement extensions | `applescript/09-use-statement.md` |
| Pipe-delimited identifiers | `applescript/01-lexical-conventions.md` (search for `|`) — needs an external scanner |
| Quote-aware block comments | `external-scanner/01-scanner-c.md` + `ts-external-scanners.txt` |
| Context-sensitive `alias` | `external-scanner/01-scanner-c.md` — define an external token that consumes `alias` only when the next non-whitespace token isn't `of` |
| Highlights / outline / runnables changes | `zed-extensions/01-language-extensions.md`, `tree-sitter/02-queries-and-highlights.md` |
