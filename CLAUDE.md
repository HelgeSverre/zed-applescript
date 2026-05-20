# CLAUDE.md

Guidance for AI coding agents working in this repo. `AGENTS.md` is a symlink to this file so Codex and other agents pick up the same instructions. The README covers user-facing features and the dev command list — this file covers only what an agent needs that isn't already there.

## What this is

A Zed editor extension providing AppleScript language support. The extension is **declarative** — no Rust or WASM. It ships only `extension.toml`, Zed tree-sitter query files under `languages/applescript/`, and pins a specific commit of an external tree-sitter grammar.

## Repository layout

- `extension.toml` — Zed extension manifest. The `[grammars.applescript]` block pins the grammar repo (`HelgeSverre/tree-sitter-applescript`) to a specific `commit` SHA. Zed fetches and builds the grammar from that pin; the submodule is for local development only.
- `languages/applescript/` — Zed query files (`highlights.scm`, `indents.scm`, `outline.scm`, `brackets.scm`, `textobjects.scm`, `runnables.scm`, `injections.scm`, `overrides.scm`), `config.toml` (file extensions, comment syntax, indentation, autoclose_before, brackets), and `tasks.json`. Queries target node names produced by the pinned grammar — if a query references a node the grammar doesn't emit, highlighting/outline silently breaks. **Always run `just verify`** — it cross-checks every node reference against the freshly-generated `src/node-types.json`.
- Markdown fence injection works out of the box. Zed matches the fence info-string case-insensitively against the language `name` and `path_suffixes`, so ```applescript`, ```AppleScript`, and ```scpt` all light up.
- `grammars/tree-sitter-applescript/` — git submodule for the grammar source. Used to regenerate the parser and test queries locally; **not shipped** with the extension.

## Critical workflow: grammar ↔ extension coupling

The grammar pin in `extension.toml` and the queries in `languages/applescript/` must stay in sync:

- **Editing only `.scm` query files**: no grammar rebuild needed, but reload the dev extension in Zed to see effects.
- **Editing the grammar** (`grammars/tree-sitter-applescript/grammar.js`): run `just build` to regenerate, commit inside the submodule, push the grammar repo, then `just update-grammar` here to advance the pin. Without updating the pin, Zed still fetches the old grammar.
- **Releasing**: `just release X.Y.Z` runs `update-grammar` first, then `verify` (fails the release if any `.scm` node reference is stale), then commits + tags. The published version always points at the latest grammar `main`.

## Conventions

- AppleScript indentation in `config.toml` is `tab_size = 4`, `hard_tabs = true` — match this in any example snippets and test fixtures.
- File extensions handled: `.applescript`, `.scpt`.
