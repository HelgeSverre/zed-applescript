### Calculate Circle Area using 'pi' Constant in AppleScript

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_fundamentals.html

Utilize the predefined 'pi' global constant for mathematical calculations involving circles. This constant represents the ratio of a circle's circumference to its diameter.

```applescript
set circleArea to pi * 7 * 7 --result: 153.9380400259
```

--------------------------------

### Saving and Restoring Text Item Delimiters in AppleScript

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_fundamentals.html

Provides an error handling structure to save the current `text item delimiters`, use custom delimiters, and restore them afterward, ensuring consistent behavior.

```applescript
set savedDelimiters to AppleScript's text item delimiters
```

```applescript
try
```

```applescript
    set AppleScript's text item delimiters to {"**"}
```

```applescript
    --other script statements...
```

```applescript
    --now reset the text item delimiters:
```

```applescript
    set AppleScript's text item delimiters to savedDelimiters
```

```applescript
on error m number n
```

```applescript
    --also reset text item delimiters in case of an error:
```

```applescript
    set AppleScript's text item delimiters to savedDelimiters
```

```applescript
    --and resignal the error:
```

```applescript
    error m number n
```

```applescript
end try
```

--------------------------------

### Using missing value Constant

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_fundamentals.html

Use the 'missing value' constant as a placeholder for uninitialized or missing information. It's useful for tracking variable changes.

```applescript
set myVariable to missing value
```

```applescript
-- perform operations that might change the value of myVariable
```

```applescript
if myVariable is equal to missing value then
    -- the value of the variable never changed
else
    -- the value of the variable did change
end if
```

### Global Constants in AppleScript > AppleScript Constant > Text Constants

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_fundamentals.html

AppleScript defines text properties `space`, `tab`, `return`, `linefeed`, and `quote`. These properties are used as text constants to represent white space or a double quote character.

--------------------------------

### Special String Characters

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_classes.html

AppleScript defines whitespace constants for representing different types of spaces: `space` for a space character, `tab` for a tab character, `return` for a return character, and `linefeed` for a linefeed character (available from AppleScript 2.0). These constants are properties of the global constant `AppleScript`.
