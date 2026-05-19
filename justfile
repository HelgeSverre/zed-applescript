# Show available commands
default:
    @just --list

# Initialize/update the grammar submodule
init:
    git submodule update --init --recursive

# Build/generate the tree-sitter parser
build:
    cd grammars/tree-sitter-applescript && npm install && npm run generate

# Verify every node referenced in languages/applescript/*.scm exists in the
# freshly-generated parser. Catches silent breakage when a grammar bump
# renames or removes a node — without this gate, queries reference dead
# nodes and Zed silently drops the rule.
verify:
    #!/usr/bin/env bash
    set -euo pipefail

    cd grammars/tree-sitter-applescript
    npx tree-sitter generate >/dev/null
    cd ../..

    # Named nodes the parser actually produces.
    KNOWN=$(jq -r '.[] | select(.named == true) | .type' \
        grammars/tree-sitter-applescript/src/node-types.json | sort -u)

    # Node references in .scm files. Strip `;` comments first, then
    # extract `(name` where name is a node-type identifier (lowercase
    # underscore words). Field labels like `command:` are filtered out
    # by requiring the name NOT be followed by `:`. Captures (`@name`)
    # and predicates (`#name?`) don't match `(name` and are ignored.
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

# Test the grammar parses correctly
test:
    #!/usr/bin/env bash
    set -e
    echo "Testing grammar..."
    cd grammars/tree-sitter-applescript
    echo 'set x to 5' | npx tree-sitter parse /dev/stdin
    echo ""
    echo 'on sayHello(name)
        return "Hello"
    end sayHello' | npx tree-sitter parse /dev/stdin
    echo ""
    echo "✓ All tests passed"

# Install dev extension in Zed
install:
    @echo "To install dev extension:"
    @echo "1. Open Zed"
    @echo "2. Cmd+Shift+P → 'zed: install dev extension'"
    @echo "3. Select this directory: $(pwd)"

# Update submodule to latest and update extension.toml
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

# Bump version and prepare release. Runs `verify` as a pre-tag gate so
# a silent .scm/grammar drift can't ship.
release version:
    #!/usr/bin/env bash
    set -e

    # Update version in extension.toml
    sed -i '' "s/^version = \".*\"/version = \"{{version}}\"/" extension.toml

    # Ensure submodule is up to date
    just update-grammar

    # Verify every .scm node reference resolves against the newly-pinned grammar.
    # Fails the release if anything is stale.
    just verify

    # Commit
    git add -A
    git commit -m "Release v{{version}}"

    # Tag it
    git tag -a "v{{version}}" -m "Release v{{version}}"

    echo ""
    echo "Release v{{version}} prepared!"
    echo "Run 'git push && git push --tags' to publish"

# Push everything
push:
    git push origin main
    git push origin --tags
