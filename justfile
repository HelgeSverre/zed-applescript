# Generate tree-sitter parser
help:
    just --list

build:
    cd grammars/applescript && npm install && npx tree-sitter generate

# Update the grammar git repo for local dev
update-grammar:
    cd grammars/applescript && git add -A && git commit -m "Update grammar" || true

# Install dev extension in Zed
install:
    @echo "Open Zed and run 'zed: install dev extension', then select this directory"
