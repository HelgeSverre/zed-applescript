# Goal: Full AppleScript support in the Zed extension

## End state

A user opening any real-world AppleScript file in Zed gets:
- Zero parse errors across a curated corpus of real `.applescript` files
- Correct, consistent highlighting for every construct the language supports
- Working indent / outline / bracket-match / text-object behavior for every block form
- A working "run this handler" gutter action that actually runs *just that handler*
- File associations that cover what users actually have on disk

You are done when **all** of the following hold:

1. The corpus in `grammars/tree-sitter-applescript/test/corpus/realworld/` parses with **zero `ERROR` and zero `MISSING` nodes** under `npx tree-sitter parse`.
2. Every node type referenced in `languages/applescript/*.scm` exists in the current generated parser (no silent query failures).
3. The matrix in `README.md` has no remaining ⚠️ rows under "Editor / structural features" or "File handling", and the "Grammar coverage" table has been updated to reflect any constructs you added.
4. `just build && just test` passes.
5. The extension loads in Zed as a dev extension and a quick smoke test (open one file from each corpus category, eyeball the highlights and outline) looks correct.
6. Grammar changes are committed and **pushed** to the grammar repo, and `extension.toml`'s `commit` pin is updated to the new SHA.

If you hit three consecutive work iterations where the ERROR-node count in the corpus doesn't decrease and no checklist item moves from ⚠️/❌ to ✅, stop and report — you've hit diminishing returns and need human input.

## Constraints

- **Two repos.** Grammar lives in the submodule (`grammars/tree-sitter-applescript/`, its own git remote). Queries and config live in this repo. Don't conflate commits across them. Workflow: change grammar → `npm run generate` inside the submodule → commit there → push grammar repo → return to outer repo → `just update-grammar` to bump the pin → commit outer repo.
- **No invented features.** If you're not sure whether AppleScript syntax X exists, find a real script that uses it (Apple's Script Editor examples, GitHub search, the macOS `/Library/Scripts/` folder, the *AppleScript Language Guide*) before adding a rule for it.
- **Don't ship LSP, formatter, or debugger work.** No language server exists. Leave the "Code intelligence" matrix rows as ❌.
- **Match existing style.** Hard tabs, 4-space tab width in any examples. Query files use `;` comments and the existing capture naming.
- **Ask before destructive grammar restructuring.** Small rule additions: just do it. Refactoring the precedence of expression rules or renaming widely-used nodes: pause and confirm — query files will silently break.

## Phase 1 — Corpus

Before touching any code: build a representative corpus.

1. Create `grammars/tree-sitter-applescript/test/corpus/realworld/` and populate it with at least 20 real AppleScript snippets, drawn from at least these sources:
   - macOS `/Library/Scripts/` (Apple-shipped examples — these are the authoritative "what real AppleScript looks like")
   - `/System/Library/CoreServices/.../Scripts/` if accessible
   - GitHub `language:applescript` search, sampling popular repos (Alfred workflows, Keyboard Maestro exports, automation scripts, BetterTouchTool, Hammerspoon-adjacent)
   - Apple's *AppleScript Language Guide* code examples (PDF on developer.apple.com)
2. Categorize them in subfolders: `tell_blocks/`, `handlers/`, `object_specifiers/`, `asobjc/` (ObjC bridge), `studio/` (legacy AppleScript Studio if any), `idioms/` (one-liners, list comprehensions via repeat, etc.), `edge_cases/`.
3. Run `npx tree-sitter parse <file>` on each. Record an `ERRORS.md` in that folder listing every ERROR/MISSING with file:line and the surrounding tokens. This is your worklist.

Verification gate: ERRORS.md exists and lists at least every parse failure across the corpus.

## Phase 2 — Grammar gaps (submodule)

Work through ERRORS.md, lowest-hanging first. Known suspects to investigate — not a guaranteed list, verify each against actual usage before adding:

- **`whose` and `where` clauses** in object specifiers (`every file whose name contains "foo"`)
- **`every` / `first` / `last` / `some` / `middle` / `any`** element specifiers
- **`beginning of` / `end of` / `before` / `after`** insertion points
- **Date literals** — `date "Saturday, January 1, 2000 at 12:00:00 AM"`
- **Continuation character** `¬` (U+00AC) joining lines mid-statement
- **ASObjC bridge** — `current application's NSString's stringWithString_("x")`, `(NSWorkspace's sharedWorkspace)'s ...`, method names with trailing underscores for ObjC selectors with colons
- **Smart quotes** in source — many real files use `"..."` not `"..."`; decide whether to accept both or normalize
- **AppleScript Studio** (legacy, pre-2011) — `on clicked theObject`, `tell window "Main"`, `call method ... of class ...`. Decide whether to support; if not, document the cutoff in README.
- **`considering / ignoring … but`** combined forms
- **`with` clauses** on commands — `display dialog "x" with icon stop with title "y"`
- **`given` clauses with multiple labeled parameters**
- **`return` without value** vs `return X`
- **Implicit run handler** — top-level statements form an implicit `on run … end run`
- **`script` objects nested inside handlers**, anonymous scripts assigned to variables
- **`exit repeat`** as a two-keyword statement
- **`'s` possessive** (`window 1's name`)

For each gap: write a corpus test in `test/corpus/<category>.txt` showing the expected tree, add the grammar rule, run `npm run generate && npx tree-sitter test`, fix until green.

Verification gate at end of phase: corpus parses with zero ERRORs, `tree-sitter test` passes, grammar repo has a clean commit history.

## Phase 3 — Query / config gaps (outer repo)

Once the grammar is stable:

1. **Sync `extension.toml`** — `just update-grammar` to pin the new grammar SHA.
2. **`injections.scm`** — new file. Inject `bash`/`sh` into the string content of `do shell script "..."` calls. Investigate whether `run script` should inject AppleScript. Verify via the grammar that string content is queryable (you may need a more granular node than `string` — if so, that's a Phase 2 grammar change, loop back).
3. **`first_line_pattern`** in `languages/applescript/config.toml` — regex for `^#!.*osascript`.
4. **`brackets` array** in `config.toml` — explicit auto-close pairs for `()`, `{}`, `""`, and `(* *)`. Test in dev extension; AppleScript's curly-quote tradition may need `autoclose_before` tuning.
5. **`.scptd` registration** — investigate first; `.scptd` is a *package* (directory), not a file. Most likely outcome: skip and document. If Zed can open the bundle's `Scripts/main.scpt`, set up accordingly.
6. **Per-handler `runnables.scm` + `tasks.json`** — current setup re-runs the whole file. Use `$ZED_SYMBOL` (the captured handler name) to actually invoke just that handler: shell into `osascript -e 'tell script of POSIX file "$ZED_FILE" to $ZED_SYMBOL()'` or similar. Verify the invocation actually works for a script with multiple handlers.
7. **Expand `highlights.scm`** to cover any new grammar nodes from Phase 2.
8. **Expand `outline.scm`** so e.g. `script` objects nested in handlers still appear, and `use` statements optionally show top-of-file imports.
9. **Expand `textobjects.scm`** for new block forms.

Verification gate: install the dev extension in Zed (`just install` instructions), open one file from each corpus category, confirm highlights/outline/indent render correctly. Capture findings as a short checklist in your final report.

## Phase 4 — Docs & release prep

1. Update `README.md` matrix: move every ⚠️ → ✅ that you fixed, add ✅ rows for new grammar constructs.
2. Update `CHANGELOG.md` with a single entry summarizing the work.
3. Do **not** bump the version or tag — leave `just release` for human invocation. Just stage the changes and report.

## How to work

- Use TaskCreate to track Phase 1–4 as top-level tasks and the contents of `ERRORS.md` as subtasks under Phase 2.
- After every grammar change, run `npm run generate` inside the submodule before you parse anything — stale generated parser will lie to you.
- Don't accumulate dozens of grammar changes before testing. After each rule add: regenerate, run the relevant corpus file, fix, commit. Small steps.
- When a corpus parse looks right but a query stops working, the issue is almost always a node rename — grep `languages/applescript/*.scm` for the old name and update.
- Final report (under 300 words): what changed in grammar (rule count delta, list of new constructs), what changed in queries/config, current ERROR count across corpus, any items deliberately deferred and why.
