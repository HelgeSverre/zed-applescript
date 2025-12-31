# AppleScript for Zed

AppleScript language support for the [Zed](https://zed.dev) editor.

## Features

- Syntax highlighting for AppleScript
- Support for `.applescript` and `.scpt` file extensions
- Line comments (`--`) and block comments (`(* *)`)
- Auto-indentation for block structures
- Code outline showing handlers, properties, and tell blocks
- Bracket matching
- Vim-style text objects

## Installation

1. Open Zed
2. Open the command palette (`Cmd+Shift+P`)
3. Search for "zed: extensions"
4. Search for "AppleScript" and click Install

## Supported Syntax

- **Handlers**: `on`/`to` ... `end`
- **Tell blocks**: `tell application` ... `end tell`
- **Control flow**: `if`/`then`/`else`, `repeat`, `try`/`on error`
- **Blocks**: `considering`, `ignoring`, `with timeout`, `with transaction`, `using terms from`
- **Declarations**: `property`, `set`, `local`, `global`
- **Use statements**: `use application`, `use framework`, `use scripting additions`

## Example

```applescript
use AppleScript version "2.4"
use scripting additions

property greeting : "Hello"

on sayHello(name)
    tell application "System Events"
        display dialog greeting & ", " & name & "!"
    end tell
end sayHello

sayHello("World")
```

## Development

To test locally:

1. Clone this repository
2. Open Zed
3. Run "zed: install dev extension" from the command palette
4. Select the cloned directory

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details.
