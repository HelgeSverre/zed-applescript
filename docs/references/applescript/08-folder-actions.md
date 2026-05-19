### Folder Action Script Handler: adding folder items to

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_folder_actions.html

This handler is invoked automatically after items are added to a folder associated with a Folder Action script. It receives the folder alias and a list of aliases for the added items.

```APIDOC
## on adding folder items to _alias_ after receiving _listOfAlias_

### Description
A script handler that is invoked after items are added to its associated folder.

### Method
Automatic invocation by the system when items are added to a folder with an associated Folder Action.

### Endpoint
N/A (This is a script handler, not a network endpoint)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Handler Syntax
```applescript
on adding folder items to _alias_ after receiving _listOfAlias_
  [ _statement_ ]...
end [ adding folder items to ]
```

### Parameters
#### Handler Parameters
- **_alias_** (alias) - Required - An alias that identifies the folder that received the items.
- **_listOfAlias_** (list of alias) - Required - List of aliases that identify the items added to the folder.

#### Script Statements
- **_statement_** (AppleScript statement) - Any AppleScript statement can be used within the handler.
```

--------------------------------

### Folder Action: Handle Item Removal Example

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_folder_actions.html

This Folder Action handler is triggered when items are removed from a folder. It displays an alert showing the number of items removed and the name of the folder.

```applescript
on removing folder items from this_folder after losing these_items
```

```applescript
    tell application "Finder"
```

```applescript
        set this_name to the name of this_folder
```

```applescript
    end tell
```

```applescript
    set the item_count to the count of these_items
```

```applescript
    display dialog (item_count as text) & " items have been removed " & "from folder \"" & this_name & "." buttons {"OK"} default button 1
```

```applescript
end removing folder items from
```

--------------------------------

### Restore Folder Window to Original Position

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_folder_actions.html

This Folder Action handler is invoked when a folder's associated window is moved or resized. It resets the folder window to its original coordinates. Note: Folder Actions may not activate this script when the folder is moved in OS X v10.5 and possibly earlier versions.

```applescript
on moving folder window for this_folder from original_coordinates
    tell application "Finder"
        set this_name to the name of this_folder
        set the bounds of the container window of this_folder \
            to the original_coordinates
    end tell
    display dialog "Window \"" & this_name & "\" has been returned to its original size and position." buttons {"OK"} default button 1
end moving folder window for
```

--------------------------------

### Close Windows of Folders within a Folder

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_folder_actions.html

This Folder Action handler is triggered when a folder's associated window is closed. It iterates through all subfolders within the target folder and attempts to close their respective windows. Designed for OS X v10.2 and later.

```applescript
-- This script is designed for use with OS X v10.2 and later.
on closing folder window for this_folder
    tell application "Finder"
        repeat with EachFolder in (get every folder of folder this_folder)
            try
                close window of EachFolder
            end try
        end repeat
    end tell
end closing folder window for
```

--------------------------------

### Folder Action: Handle Folder Opening

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_folder_actions.html

This Folder Action handler is triggered when a folder is opened. It displays text from the Spotlight Comments field or the Comments field (prior to OS X v10.4). Requires OS X v10.2 or later.

```applescript
-- This script is designed for use with OS X v10.2 and later.
```

```applescript
property dialog_timeout : 30 -- set the amount of time before dialogs auto-answer.
```

```applescript
on opening folder this_folder
```

```applescript
    tell application "Finder"
```

```applescript
        activate
```

```applescript
        set the alert_message to the comment of this_folder
```

```applescript
        if the alert_message is not "" then
```

```applescript
            display dialog alert_message buttons {"Open Comments", "Clear Comments", "OK"} default button 3 giving up after dialog_timeout
```

```applescript
            set the user_choice to the button returned of the result
```

```applescript
            if the user_choice is "Clear Comments" then
```

```applescript
                set comment of this_folder to ""
```

```applescript
            else if the user_choice is "Open Comments" then
```

```applescript
                open information window of this_folder
```

```applescript
            end if
```

```applescript
        end if
```

```applescript
    end tell
```

```applescript
end opening folder
```
