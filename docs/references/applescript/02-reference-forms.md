### Index Reference Form Example

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_reference_forms.html

An example of an object specifier using index reference forms to identify an object by its number within a container. This form requires specifying the container.

```applescript
item 1 of second folder of disk 1
```

--------------------------------

### Get Middle Object in AppleScript

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_reference_forms.html

Use the 'middle' reference form to get the middle item from a list or collection. This works for lists with an odd or even number of elements.

```applescript
tell application "TextEdit"
end tell
```

```applescript
middle paragraph of front document
```

```applescript
middle item of {1, "doughnut", 33}
```

```applescript
middle item of {1, "doughnut", 22, 33}
```

```applescript
middle item of {1, "doughnut", 11, 22, 33}
```

--------------------------------

### Specify Every Word in a Text String

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_reference_forms.html

This example demonstrates how to use the 'every' reference form to specify all words within a given text string. The result is a list of the words.

```applescript
set myText to "That's all, folks"
every word of myText --result: {"That's", "all", "folks"} (a list of three words)
```

### AppleScript Language Guide > Reference Forms

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/Index/index_of_book.html

Reference forms provide various ways to refer to objects and their properties, including arbitrary, filter, ID, index, middle, name, property, range, and relative forms.

--------------------------------

### AppleScript Language Guide > Conceptual > Object Specifier

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_glossary.html

An object specifier is the syntax used to identify an object or a group of objects within an application or other container. AppleScript supports various reference forms for constructing these specifiers, including arbitrary, every, filter, ID, index, middle, name, property, range, and relative.
