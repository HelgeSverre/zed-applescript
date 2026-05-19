### Implement AI Assistant Slash Commands (Rust)

Source: https://context7.com/mrtomatepng/zed_extension_api/llms.txt

Shows how to integrate custom slash commands into Zed's AI Assistant. This involves implementing `complete_slash_command_argument` for argument suggestions and `run_slash_command` to execute the command's logic, potentially fetching dynamic content or external data.

```rust
use zed_extension_api::{
    Extension, SlashCommand, SlashCommandOutput, SlashCommandOutputSection,
    SlashCommandArgumentCompletion, Worktree, Result,
};

struct DocsExtension;

impl Extension for DocsExtension {
    fn new() -> Self {
        DocsExtension
    }

    fn complete_slash_command_argument(
        &self,
        command: SlashCommand,
        args: Vec<String>,
    ) -> Result<Vec<SlashCommandArgumentCompletion>, String> {
        if command.name == "docs" {
            Ok(vec![
                SlashCommandArgumentCompletion {
                    label: "rust".to_string(),
                    new_text: "rust".to_string(),
                    run_command: true,
                },
                SlashCommandArgumentCompletion {
                    label: "typescript".to_string(),
                    new_text: "typescript".to_string(),
                    run_command: true,
                },
            ])
        } else {
            Ok(vec![])
        }
    }

    fn run_slash_command(
        &self,
        command: SlashCommand,
        args: Vec<String>,
        worktree: Option<&Worktree>,
    ) -> Result<SlashCommandOutput, String> {
        let topic = args.first().cloned().unwrap_or_default();

        let content = match topic.as_str() {
            "rust" => "# Rust Documentation\n\nRust is a systems programming language...".to_string(),
            "typescript" => "# TypeScript Documentation\n\nTypeScript is a typed superset of JavaScript...".to_string(),
            _ => format!("Documentation for '{}' not found.", topic),
        };

        Ok(SlashCommandOutput {
            sections: vec![SlashCommandOutputSection {
                range: (0..content.len()).into(),
                label: format!("Docs: {}", topic),
            }],
            text: content,
        })
    }
}
```

--------------------------------

### Language Server Protocol (LSP) Module

Source: https://github.com/mrtomatepng/zed_extension_api/blob/master/index.html

Enables interaction with language servers using the Language Server Protocol. This module is crucial for integrating features like code completion, diagnostics, and go-to-definition.

```rust
mod lsp
```

### Zed Extension API > Extension Trait - Core Extension Interface

Source: https://context7.com/mrtomatepng/zed_extension_api/llms.txt

The `Extension` trait is the primary interface that all Zed extensions must implement. It provides hooks for language server management, debug adapter configuration, slash commands, context servers, and documentation indexing. Only the `new()` method is required; all other methods have default implementations.

--------------------------------

### Zed Extension API

Source: https://context7.com/mrtomatepng/zed_extension_api/llms.txt

The Zed Rust Extension API (version 0.7.0) allows developers to write extensions for Zed in Rust. This crate provides a comprehensive framework for extending Zed's functionality, including support for language servers, debug adapters, slash commands for the AI assistant, context servers, and documentation indexing. Extensions are compiled to WebAssembly and run in a sandboxed environment within Zed.

The API is organized into several modules: the core `Extension` trait that all extensions must implement, an HTTP client for making web requests, process execution utilities, LSP (Language Server Protocol) constructs, and settings access. Extensions can integrate with external tools, download and manage binaries, interact with the filesystem through worktrees, and provide custom functionality to enhance the Zed editing experience.

--------------------------------

### Slash Commands - AI Assistant Integration

Source: https://context7.com/mrtomatepng/zed_extension_api/llms.txt

Extensions can provide custom slash commands for Zed's AI Assistant. These commands can generate dynamic content, fetch external data, or provide specialized functionality. Implement `complete_slash_command_argument` for argument completions and `run_slash_command` to execute the command.
