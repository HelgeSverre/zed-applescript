### Register Tree-sitter Grammar in extension.toml

Source: https://github.com/zed-industries/zed/blob/main/docs/src/extensions/languages.md

Register a Tree-sitter grammar for a language by specifying its repository URL and a Git revision. This allows Zed to use the grammar for parsing and language-specific features. Local development can use `file://` URLs for the repository.

```toml
[grammars.gleam]
repository = "https://github.com/gleam-lang/tree-sitter-gleam"
rev = "58b7cac8fc14c92b0677c542610d8738c373fa81"
```

--------------------------------

### Define Language Metadata with config.toml

Source: https://github.com/zed-industries/zed/blob/main/docs/src/extensions/languages.md

Configure language-specific settings such as name, grammar association, file suffixes, and line comment syntax. This file is essential for Zed to recognize and properly handle a new language.

```toml
name = "My Language"
grammar = "my-language"
path_suffixes = ["myl"]
line_comments = ["# "]
```

--------------------------------

### Registering Snippet Files in extension.toml

Source: https://github.com/zed-industries/zed/blob/main/docs/src/extensions/snippets.md

This TOML snippet demonstrates how to specify the paths to snippet files within an extension's configuration. The paths are relative to the extension.toml file, and Zed uses the filename's lowercase language name to associate snippets with buffers. A special filename `snippets.json` can be used for snippets available in any buffer.

```toml
snippets = ["./snippets/rust.json", "./snippets/typescript.json"]
```

### Language Extensions > Language Metadata

Source: https://github.com/zed-industries/zed/blob/main/docs/src/extensions/languages.md

Each language supported by Zed requires a subdirectory within the extension's `languages` directory. This subdirectory must contain a `config.toml` file defining essential language properties such as its human-readable name, the associated grammar, file suffixes, line comment indicators, indentation settings, and patterns for identifying the language.

--------------------------------

### Language Extensions > Grammar

Source: https://github.com/zed-industries/zed/blob/main/docs/src/extensions/languages.md

Zed utilizes the Tree-sitter parsing library to enable language-specific features. Grammars for various languages are available, and custom grammars can be developed. These grammars are crucial for features implemented through pattern matching on syntax trees using Tree-sitter queries. Each language defined in an extension must specify a Tree-sitter grammar, which is then registered in the extension's `extension.toml` file, referencing the grammar's repository and a specific Git revision.
