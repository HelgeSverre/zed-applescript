### Date Object Properties

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_classes.html

Properties of a date object in AppleScript. These include class, day, weekday, month, year, time, date string, and time string.

```applescript
class
```

```applescript
day
```

```applescript
weekday
```

```applescript
month
```

```applescript
year
```

```applescript
time
```

```applescript
date string
```

```applescript
short date string of (current date) --result: "1/27/08"
```

```applescript
time string
```

--------------------------------

### Integer to Number Coercion in AppleScript

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_classes.html

Demonstrates coercing an integer to a number type, which results in no change to the value. The 'class of' command confirms the type remains 'integer'.

```applescript
set myCount to 7 as number
```

```applescript
class of myCount --result: integer
```

--------------------------------

### Coerce Value with Ordered Class List

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_operators.html

Demonstrates how the order of classes in the 'as' operator affects coercion. '1.5 as {integer, text}' results in 2, while '1.5 as {text, integer}' results in '1.5'.

```AppleScript
1.5 as {integer, text}
```

```AppleScript
1.5 as {text, integer}
```

--------------------------------

### Text Type Synonyms in AppleScript

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_classes.html

Demonstrates that 'text', 'string', and 'Unicode text' are treated as synonyms for type coercion and comparison in AppleScript versions prior to 2.0.

```applescript
someObject as text
```

```applescript
someObject as string
```

```applescript
someObject as Unicode text
```

### unit types

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_classes.html

Unit types are used for measurements of length, area, cubic and liquid volume, mass, and temperature. Unit type classes represent simple objects with a single `class` property. Supported unit classes include various measurements for length (e.g., `centimetres`, `feet`, `miles`), area (e.g., `square feet`, `square kilometers`), cubic volume (e.g., `cubic meters`), liquid volume (e.g., `gallons`, `liters`), weight (e.g., `grams`, `pounds`), and temperature (e.g., `degrees Celsius`, `degrees Fahrenheit`).
