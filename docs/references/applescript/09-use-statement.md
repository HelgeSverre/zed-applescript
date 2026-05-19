### Declare Use of AppleScript with Minimum Version

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_control_statements.html

Explicitly specifies a minimum required version of AppleScript (e.g., 2.3.2). The version string is compared numerically.

```applescript
use AppleScript version "2.3.2"
```

--------------------------------

### Import Application with an Identifier in AppleScript

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_control_statements.html

Imports an application and assigns it a local identifier for easier reference within the script.

```applescript
use Safari : application "Safari"
```

--------------------------------

### Specify Terminology with 'using terms from'

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_control_statements.html

Use 'using terms from' to specify the terminology AppleScript should use when compiling statements within a script. This is useful for application event handler scripts or when targeting remote applications.

```applescript
using terms from application "Mail"
```

```applescript
on perform mail action with messages theMessages for rule theRule
```

```applescript
    tell application "Mail"
```

```applescript
        -- statements to process each message in theMessages
```

```applescript
    end tell
```

```applescript
end perform mail action with messages
```

```applescript
end using terms from
```

--------------------------------

### Import WebKit Framework for AppleScript/Objective-C Bridge

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_control_statements.html

Declares the 'WebKit' framework for use with the AppleScript/Objective-C bridge. This is useful for web-related functionalities.

```applescript
use framework "WebKit"
```

### use Statements

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_control_statements.html

A `use` statement declares a required resource for a script, such as an application, script library, framework, or a specific version of AppleScript. It can also optionally import terminology from the resource, making it available for use within the script. The behavior and syntax of `use` statements vary depending on the type of resource being used.
