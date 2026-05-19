### Valid AppleScript Identifier Characters

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_lexical_conventions.html

An identifier must begin with a letter and can contain letters, numbers, and underscores. Identifiers are not case-sensitive.

```plaintext
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_
```

--------------------------------

### AppleScript Shebang for Executable Scripts

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_lexical_conventions.html

Starting with version 2.0, '#' can be used as an end-of-line comment. Prefixing a script with '#!/usr/bin/osascript' allows it to be run as a Unix executable.

```applescript
#!/usr/bin/osascript
```

--------------------------------

### AppleScript Text Literal

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_lexical_conventions.html

A text literal consists of a sequence of Unicode characters enclosed in double quote marks.

```applescript
"A basic string."
```

--------------------------------

### Define a List with Mixed Data Types

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_classes.html

Create a list containing text, an integer, and a boolean value.

```applescript
{ "it's", 2, true }
```

### Organization of This Document > AppleScript Lexical Conventions

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/index.html

AppleScript Lexical Conventions describes the characters, symbols, keywords, and other language elements that make up statements in an AppleScript script.
