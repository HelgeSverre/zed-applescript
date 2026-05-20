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

## Local install for development

```bash
just install      # symlinks $(pwd) → ~/Library/Application Support/Zed/extensions/installed/applescript
just dev          # runs verify, then `zed --new example`
```

Once `just install` has been run once, every change to a `.scm` file is picked up automatically by Zed on file reload (or via `cmd-shift-P → zed: rebuild dev extension`). Grammar pin changes auto-trigger Zed's grammar rebuild.

`just install-via-ui` exists as a fallback that prints the manual GUI flow (`cmd-shift-P → zed: install dev extension`) — use it when you want Zed to compile the extension via its own builder instead of the symlink shortcut.

## Release process

Two flavours: **extension-only changes** (`.scm`/config edits, tasks, README) and **grammar changes** (touch `grammar.js`, the external scanner, or test corpus). Both go through the same release path; the difference is what gets committed before `just release` runs.

### Step 1 — Grammar changes (skip if extension-only)

Work happens in the submodule:

```bash
cd grammars/tree-sitter-applescript
# edit grammar.js / src/scanner.c / test/corpus
npx tree-sitter generate        # regenerate src/parser.c
npx tree-sitter test            # fixture suite (94+ tests)
# verify a few realworld files still parse 0 ERROR
for f in $(find test/corpus/realworld -name '*.applescript' -not -path '*/known-limits/*'); do
  out=$(npx tree-sitter parse "$f" 2>&1 | grep -E 'ERROR|MISSING')
  [ -n "$out" ] && echo "FAIL: $f"$'\n'"$out"
done
# commit + push the grammar repo
git add grammar.js src/ test/
git commit -m "feat(grammar): …"
git push origin main
cd ../..
```

### Step 2 — Extension-side edits

Edit `.scm` files in `languages/applescript/`, `tasks.json`, `config.toml`, `CHANGELOG.md`, etc.

After every change, run:

```bash
just verify       # cross-checks every .scm node reference against the freshly-generated parser
```

`verify` is also a release pre-gate, so a failing check here means a failing release.

### Step 3 — Update CHANGELOG

**Manually** before `just release`: add a `## [X.Y.Z]` section above the previous version's entry. The release commit stages CHANGELOG.md explicitly.

### Step 4 — Run the release

```bash
just release 1.8.4
```

This:
1. `sed`-rewrites `version = "…"` in `extension.toml`.
2. Calls `just update-grammar` → fast-forwards the submodule to `origin/main` of the grammar repo and rewrites the `commit = "…"` pin. No-op if the grammar hasn't moved.
3. Calls `just verify` → fails the release if any `.scm` reference is stale against the new pin.
4. `git add extension.toml grammars/tree-sitter-applescript CHANGELOG.md` (explicit paths — no `git add -A`).
5. Creates an annotated tag `vX.Y.Z`.

### Step 5 — Publish

```bash
just push       # git push origin main && git push origin --tags
```

The push triggers the GitHub Release workflow (`.github/workflows/release.yml`), which re-runs `verify` as its own gate and publishes a GitHub Release with notes extracted from `CHANGELOG.md`.

Zed's extension marketplace pulls from the published tag — give it a few hours to index, then the new version appears in `cmd-shift-P → zed: extensions`.

### What `just update-grammar` does (the load-bearing piece)

The submodule under `grammars/tree-sitter-applescript/` is for local dev only. Zed in production builds the grammar from whatever commit SHA is listed in `[grammars.applescript].commit` in `extension.toml`. `just update-grammar` keeps those two in lockstep:

1. `cd` into the submodule, `git fetch origin`, `git checkout origin/main`.
2. Captures the resulting HEAD SHA.
3. `sed`-rewrites `commit = "…"` in `extension.toml` to that SHA.
4. Stages both paths for the next commit.

Idempotent — if `origin/main` of the grammar hasn't advanced, the pin doesn't change. Always run via `just release` rather than directly during normal work; calling it manually is reserved for situations like "I want to test the current grammar tip without cutting a release."

## Conventions

- AppleScript indentation in `config.toml` is `tab_size = 4`, `hard_tabs = true` — match this in any example snippets and test fixtures.
- File extensions handled: `.applescript`, `.scpt`.
- Versioning is loose semver: bug fixes / cleanup go in `1.8.x`; new query files or grammar features bump the minor; the major hasn't moved since v1.0.
- Don't run `just release` to ship a grammar change you haven't already pushed to the grammar repo's `main` — `update-grammar` will fetch the older state.
