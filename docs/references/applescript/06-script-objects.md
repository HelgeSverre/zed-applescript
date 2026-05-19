### Define Parent and Child Script Objects in AppleScript

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_script_objects.html

Defines a parent script object 'Alex' and a child script object 'AlexJunior' that inherits from 'Alex'. The child overrides the 'getName' handler.

```applescript
script Alex
    on sayHello()
        return "Hello, " & getName()
    end sayHello
    on getName()
        return "Alex"
    end getName
end script
```

```applescript
script AlexJunior
    property parent : Alex
    on getName()
        return "Alex Jr"
    end getName
end script
```

--------------------------------

### Child Script Modifying Inherited Property in AppleScript

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_script_objects.html

Demonstrates a child script 'JohnSon' modifying an inherited property ('vegetable') from its parent 'John'. This change also updates the property in the parent script.

```applescript
script John
    property vegetable : "Spinach"
end script
script JohnSon
    property parent : John
    on changeVegetable()
        set my vegetable to "Zucchini"
    end changeVegetable
end script
```

```applescript
tell JohnSon to changeVegetable()
```

```applescript
vegetable of John
--result: "Zucchini"
```

### Inheritance in Script Objects > Defining Inheritance Through the parent Property

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_script_objects.html

Inheritance in AppleScript enables a child script object to adopt the properties and handlers of a parent object. This relationship is established using the `parent` property. The object designated in the `parent` property is known as the parent object, while the script object containing this property is the child script object.

--------------------------------

### Inheritance in Script Objects > Defining Inheritance Through the parent Property

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_script_objects.html

While the `parent` property is optional, its absence means all scripts default to being children of the top-level script. A parent object can have multiple children, but a child script object can only have one parent. The parent can be any object type, such as a list or application object, but is most commonly another script object.

--------------------------------

### Conceptual AppleScript Language Guide > Some Examples of Inheritance

Source: https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/conceptual/ASLR_script_objects.html

The parent-child relationship between script objects is dynamic. Changes made to the properties of a parent script object are reflected in the inherited properties of its children. Conversely, if a child script object modifies an inherited property, the change is also applied to the parent object's property.
