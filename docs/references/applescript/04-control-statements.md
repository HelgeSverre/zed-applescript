### Compound If Statement with Else If and Else

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_control_statements.html

Execute blocks of statements based on a series of Boolean expressions. The first true condition's block is executed, or the 'else' block if no conditions are met. This is useful for branching logic.

```applescript
if currentTemp < 60 then
    set response to "It's a little chilly today."
else if currentTemp > 80 then
    set response to "It's getting hotter today."
else
    set response to "It's a nice day today."
end if

display dialog response
```

--------------------------------

### Display Dialog with Input and Error Handling

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html

Shows how to use display dialog with various parameters, including buttons, default answer, timeout, and handling user cancellation or timeout errors. Use when user interaction is required and specific outcomes need to be managed.

```applescript
set userCanceled to false
```

```applescript
try
```

```applescript
set dialogResult to display dialog ¬
        "What is your name?" buttons {"Cancel", "OK"} ¬
        default button "OK" cancel button "Cancel" ¬
        giving up after 15 ¬
        default answer (long user name of (system info))
```

```applescript
on error number -128
```

```applescript
set userCanceled to true
```

```applescript
end try
```

```applescript
if userCanceled then
    -- statements to execute when user cancels
    display dialog "User cancelled."
```

```applescript
else if gave up of dialogResult then
    -- statements to execute if dialog timed out without an answer
    display dialog "User timed out."
```

```applescript
else if button returned of dialogResult is "OK" then
    set userName to text returned of dialogResult
    -- statements to process user name
    display dialog "User name: " & userName
```

```applescript
end if
```

```applescript
end
```

--------------------------------

### Control Command Timeout with 'with timeout'

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_control_statements.html

Use 'with timeout' to specify how long AppleScript waits for a command to execute before timing out. This example sets a 20-second timeout for closing a document in TextEdit.

```applescript
tell application "TextEdit"
```

```applescript
    with timeout of 20 seconds
```

```applescript
        close document 1 saving ask
```

```applescript
    end timeout
```

```applescript
end tell
```

### AppleScript Language Guide > Conceptual > AppleScript Language Guide

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/Index/index_of_book.html

Control statements manage the flow of execution within a script. This includes conditional statements like `if...then...else`, looping constructs like `repeat`, and statements for error handling like `try` and `error`.

--------------------------------

### AppleScript Language Guide > Control Statements > repeat control statements

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/Index/index_of_book.html

AppleScript provides several `repeat` control statements, including `repeat forever`, `repeat number times`, `repeat until`, `repeat while`, and `repeat with` loops, to control the flow of execution.
