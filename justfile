# Build/generate the tree-sitter parser
build:
    cd grammars/applescript && npm install && npx tree-sitter generate

# Test the grammar parses correctly
test:
    @echo "Testing grammar..."
    @echo 'on sayHello(name)\n    return "Hello"\nend sayHello' | npx tree-sitter parse --stdin -q grammars/applescript || true
    cd grammars/applescript && npx tree-sitter parse /dev/stdin <<< 'set x to 5'

# Install dev extension in Zed
install:
    @echo "To install dev extension:"
    @echo "1. Open Zed"
    @echo "2. Cmd+Shift+P → 'zed: install dev extension'"
    @echo "3. Select this directory: $(pwd)"

# Update grammar commit SHA in extension.toml (run after pushing)
update-commit:
    #!/usr/bin/env bash
    COMMIT=$(git rev-parse HEAD)
    sed -i '' "s/^commit = \".*\"/commit = \"$COMMIT\"/" extension.toml
    echo "Updated extension.toml to commit $COMMIT"

# Bump version and prepare release
release version:
    #!/usr/bin/env bash
    set -e
    
    # Update version in extension.toml
    sed -i '' "s/^version = \".*\"/version = \"{{version}}\"/" extension.toml
    
    # Build grammar to make sure it works
    just build
    
    # Get current commit (before we commit version bump)
    git add -A
    git commit -m "Release v{{version}}"
    
    # Now update the commit SHA to point to THIS commit
    COMMIT=$(git rev-parse HEAD)
    sed -i '' "s/^commit = \".*\"/commit = \"$COMMIT\"/" extension.toml
    git add extension.toml
    git commit --amend --no-edit
    
    # Get the final commit SHA
    FINAL_COMMIT=$(git rev-parse HEAD)
    echo "Final commit: $FINAL_COMMIT"
    
    # Tag it
    git tag -a "v{{version}}" -m "Release v{{version}}"
    
    echo ""
    echo "Release v{{version}} prepared!"
    echo "Run 'git push && git push --tags' to publish"

# Push everything
push:
    git push origin main
    git push origin --tags
