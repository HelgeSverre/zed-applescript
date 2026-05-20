# Show available commands
default:
    @just --list

# === Grammar / build ===

# Initialize/update the grammar submodule
init:
    git submodule update --init --recursive

# Build/generate the tree-sitter parser
build:
    cd grammars/tree-sitter-applescript && npm install && npm run generate

# Run the grammar's full fixture suite + a quick smoke parse
test:
    #!/usr/bin/env bash
    set -e
    cd grammars/tree-sitter-applescript
    echo "Running fixture suite..."
    # Full output, not truncated — a failing test prints the diff before
    # the summary, and we want to see WHICH fixture broke when CI fails.
    npx tree-sitter test
    echo ""
    echo "Smoke-parse:"
    echo 'set x to 5' | npx tree-sitter parse /dev/stdin
    echo "✓ All tests passed"

# Regenerate parser + check every .scm node reference resolves
verify:
    #!/usr/bin/env bash
    set -euo pipefail

    cd grammars/tree-sitter-applescript
    npx tree-sitter generate >/dev/null
    cd ../..

    KNOWN=$(jq -r '.[] | select(.named == true) | .type' \
        grammars/tree-sitter-applescript/src/node-types.json | sort -u)

    REFS=$(sed 's/;.*$//' languages/applescript/*.scm \
        | grep -oE '\([a-z_][a-z0-9_]*' \
        | sed 's/^(//' \
        | sort -u)

    MISSING=$(comm -23 <(echo "$REFS") <(echo "$KNOWN"))

    if [ -n "$MISSING" ]; then
        echo "✗ Query references unknown node types:" >&2
        echo "$MISSING" | sed 's/^/  - /' >&2
        echo "" >&2
        echo "Check that these nodes still exist in grammar.js," >&2
        echo "or update the .scm queries to use the new node names." >&2
        exit 1
    fi

    echo "✓ All query node references resolve. ($(echo "$REFS" | wc -l | tr -d ' ') unique nodes referenced)"

# === Dev loop ===

# Symlink this dir into Zed's extensions/installed/ (one-time setup)
[macos]
install:
    #!/usr/bin/env bash
    set -e
    ZED_EXT="$HOME/Library/Application Support/Zed/extensions/installed"
    mkdir -p "$ZED_EXT"
    rm -f "$ZED_EXT/applescript"
    ln -s "$(pwd)" "$ZED_EXT/applescript"
    echo "✓ Symlinked $(pwd) → $ZED_EXT/applescript"
    echo ""
    echo "Next steps:"
    echo "  1. In Zed: cmd-shift-P → 'zed: rebuild dev extension' (or quit + relaunch)"
    echo "  2. Open example/hello.applescript or example/injection.md to test"

# Verify queries, then open example/ in a new Zed window
[macos]
dev: verify
    zed --new example

# Print manual install flow (UI-driven, lets Zed compile the extension)
install-via-ui:
    @echo "Manual install via Zed UI:"
    @echo "  1. Open Zed"
    @echo "  2. cmd-shift-P → 'zed: install dev extension'"
    @echo "  3. Pick this directory: $(pwd)"

# Show extension version, grammar pin, last tag, and working-tree status
[macos]
status:
    #!/usr/bin/env bash
    set -e

    VER=$(grep '^version' extension.toml | sed 's/^version = "\(.*\)"/\1/')
    PIN=$(grep '^commit' extension.toml | sed 's/^commit = "\(.*\)"/\1/')
    TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "(none)")
    HEAD=$(git rev-parse --short HEAD)
    DIRTY=$(git status --porcelain | wc -l | tr -d ' ')
    SUB_PIN_SHORT=${PIN:0:7}
    SUB_HEAD=$(cd grammars/tree-sitter-applescript && git rev-parse HEAD)
    SUB_HEAD_SHORT=${SUB_HEAD:0:7}

    if [ "$PIN" = "$SUB_HEAD" ]; then
        SUB_SYNC="✓ matches pin"
    else
        SUB_SYNC="⚠ submodule at $SUB_HEAD_SHORT, pin is $SUB_PIN_SHORT (run \`just update-grammar\` or check out the pinned SHA)"
    fi

    printf "extension version : %s\n" "$VER"
    printf "extension HEAD    : %s\n" "$HEAD"
    printf "last tag          : %s\n" "$TAG"
    printf "grammar pin       : %s\n" "$PIN"
    printf "submodule         : %s\n" "$SUB_SYNC"
    printf "working tree      : %s file(s) changed\n" "$DIRTY"

# === Release ===

# Update submodule to latest and rewrite the commit pin in extension.toml
update-grammar:
    #!/usr/bin/env bash
    set -e
    cd grammars/tree-sitter-applescript
    git fetch origin
    git checkout origin/main
    COMMIT=$(git rev-parse HEAD)
    cd ../..
    sed -i '' "s/^commit = \".*\"/commit = \"$COMMIT\"/" extension.toml
    echo "Updated extension.toml to grammar commit $COMMIT"
    git add grammars/tree-sitter-applescript extension.toml

# Bump version, fast-forward grammar, verify, commit, tag
release version:
    #!/usr/bin/env bash
    set -e

    sed -i '' "s/^version = \".*\"/version = \"{{version}}\"/" extension.toml

    just update-grammar
    just verify

    # Explicit paths only — `git add -A` would sweep in stray local
    # files (notes, secrets, scratch buffers) into the release commit.
    # The grammar submodule pointer and extension.toml are advanced by
    # `update-grammar`; if a release also touches CHANGELOG.md or other
    # files, add them by name above this commit step.
    git add extension.toml grammars/tree-sitter-applescript CHANGELOG.md
    git commit -m "Release v{{version}}"
    git tag -a "v{{version}}" -m "Release v{{version}}"

    echo ""
    echo "Release v{{version}} prepared. Run 'just push' to publish."

# Push main + tags
push:
    git push origin main
    git push origin --tags
