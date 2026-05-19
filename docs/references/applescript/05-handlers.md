### AppleScript Handler Definition Syntax

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_handlers.html

Defines the structure for creating an AppleScript handler with optional direct and labeled parameters. Handlers can include a return statement or rely on the last statement's value.

```applescript
( on | to )  _handlerName_ ¬
   [ [ of | in ] _directParamName_ ] ¬
   [ _ASLabel_ _userParamName_ ]... ¬
   [ given _userLabel_:_userParamName_ [, _userLabel_:_userParamName_ ]...]  
      [ _statement_ ]...
end [ _handlerName_ ]  

```

--------------------------------

### Define Handler with Labeled Parameters

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_about_handlers.html

Defines a handler that accepts labeled parameters, including a direct parameter and a special 'given' label for rounding. Use this when parameter order flexibility is desired.

```applescript
to findNumbers of numberList above minLimit given rounding:roundBoolean
```

```applescript
set resultList to {}
```

```applescript
repeat with i from 1 to (count items of numberList)
```

```applescript
set x to item i of numberList
```

```applescript
if roundBoolean then -- round the number
```

```applescript
-- Use copy so original list isn’t modified.
```

```applescript
copy (round x) to x
```

```applescript
end if
```

```applescript
if x > minLimit then
```

```applescript
set end of resultList to x
```

```applescript
end if
```

```applescript
end repeat
```

```applescript
return resultList
```

```applescript
end findNumbers
```

--------------------------------

### Call Handler with Labeled Parameters (given)

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_about_handlers.html

Calls the 'findNumbers' handler, passing a list and a minimum limit, and explicitly specifying the rounding behavior using the 'given' clause. This demonstrates passing boolean values directly.

```applescript
set myList to {2, 5, 19.75, 99, 1}
```

```applescript
findNumbers of myList above 19 given rounding:true
```

```applescript
--result: {20, 99}
```

```applescript
findNumbers of myList above 19 given rounding:false
```

```applescript
--result: {19.75, 99}
```

--------------------------------

### Call Handler with Labeled Parameters (with/without)

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_about_handlers.html

Calls the 'findNumbers' handler, passing a list and a minimum limit, using 'with' or 'without' clauses to specify the rounding behavior. AppleScript automatically converts 'given rounding:true' to 'with rounding' and 'given rounding:false' to 'without rounding'.

```applescript
findNumbers of {5.1, 20.1, 20.5, 33} above 20 with rounding
```

```applescript
--result: {33}
```

```applescript
findNumbers of {5.1, 20.1, 20.5, 33.7} above 20 without rounding
```

```applescript
--result: {20.1, 20.5, 33.7}
```

### Conceptual AppleScript Language Guide > Handlers with Labeled Parameters

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_about_handlers.html

Handlers with labeled parameters allow you to specify parameter values using labels when calling the handler. The direct parameter, if present, must follow the handler name. Other labeled parameters can be in any order, identified by their labels. Clauses like `given`, `with`, and `without` can be used to specify parameter values, and AppleScript can automatically convert between `given` and `with`/`without` clauses.
