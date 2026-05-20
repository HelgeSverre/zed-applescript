# Markdown injection smoke test

Open this file in Zed (with the dev extension installed) and verify that
the AppleScript fenced blocks below get highlighted using our queries.

A plain prose paragraph so the test starts in a markdown context.

```applescript
-- Should look exactly like the standalone .applescript files
on greet(name)
    return "Hello, " & name
end greet

tell application "Finder"
    display dialog greet("from markdown")
end tell
```

For comparison, here's a bash block that should highlight via Zed's
built-in bash injection:

```bash
echo "hi from bash"
```

And one more AppleScript block, this time exercising line continuation:

```applescript
display dialog "Pick a folder" ¬
    default location (path to home folder) ¬
    with multiple selections allowed
```

If everything above looks colored correctly, markdown ↔ applescript
injection is wired up.
