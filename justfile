# Show available commands
default:
    @just --list

# Initialize/update the grammar submodule
init:
    git submodule update --init --recursive

# Build/generate the tree-sitter parser
build:
    cd grammars/tree-sitter-applescript && npm install --ignore-scripts && npx tree-sitter generate

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

# Bump version and prepare release
release version:
    #!/usr/bin/env bash
    set -e
    
    # Update version in extension.toml
    sed -i '' "s/^version = \".*\"/version = \"{{version}}\"/" extension.toml
    
    # Ensure submodule is up to date
    just update-grammar
    
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
