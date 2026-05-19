# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## What this is

A Zed editor extension providing AppleScript language support. The extension itself is declarative (no Rust/WASM code) — it ships only `extension.toml`, Zed tree-sitter query files under `languages/applescript/`, and pins a specific commit of an external tree-sitter grammar.

## Repository layout

- `extension.toml` — Zed extension manifest. The `[grammars.applescript]` block pins the grammar repo (`HelgeSverre/tree-sitter-applescript`) to a specific `commit` SHA. Zed fetches and builds the grammar from that pin; the submodule is for local development only.
- `languages/applescript/` — Zed query files (`highlights.scm`, `indents.scm`, `outline.scm`, `brackets.scm`, `textobjects.scm`, `runnables.scm`) and `config.toml` (file extensions, comment syntax, indentation). These queries target node names produced by the pinned grammar — if a query references a node the grammar doesn't emit, highlighting/outline silently breaks.
- `grammars/tree-sitter-applescript/` — git submodule for the grammar source. Used to regenerate the parser and test queries locally; **not shipped** with the extension.
- `tree-sitter-applescript-old/` — legacy in-tree grammar kept for reference. Do not edit; the submodule is the source of truth.
- `justfile` — task runner with all common workflows.

## Common commands

```bash
just init            # git submodule update --init --recursive
just build           # cd into submodule, npm install, npm run generate (regenerates parser)
just test            # parse a couple of small AppleScript snippets via tree-sitter CLI
just update-grammar  # fast-forward submodule to origin/main and rewrite the commit pin in extension.toml
just release X.Y.Z   # bump extension.toml version, update grammar, commit, tag
just install         # prints instructions for "zed: install dev extension"
```

To load the extension in Zed for manual testing: command palette → `zed: install dev extension` → select this directory. Zed will rebuild the grammar from the pinned commit.

## Critical workflow: grammar ↔ extension coupling

The grammar pin in `extension.toml` and the queries in `languages/applescript/` must stay in sync. When making changes:

- **Editing only `.scm` query files**: no grammar rebuild needed, but reload the dev extension in Zed to see effects.
- **Editing the grammar** (`grammars/tree-sitter-applescript/grammar.js`): run `just build` to regenerate, commit inside the submodule, push the grammar repo, then run `just update-grammar` here to advance the pin. Without updating the pin, Zed will still fetch the old grammar.
- **Releasing**: `just release X.Y.Z` runs `update-grammar` first, so the published version always points at the latest grammar `main`.

## Conventions

- AppleScript indentation in `config.toml` is `tab_size = 4`, `hard_tabs = true` — match this in any example snippets and test fixtures.
- File extensions handled: `.applescript`, `.scpt`.
