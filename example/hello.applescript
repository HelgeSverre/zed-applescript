-- Minimal smoke-test for the extension. Open this file in Zed after
-- installing the dev extension and verify:
--   * Comments are dimmed
--   * Strings are highlighted
--   * `on`, `tell`, `if`, `end` are keyword-coloured
--   * The outline panel shows `greet` and `main` as handlers

use AppleScript version "2.4"
use scripting additions

property greeting : "Hello"

on greet(name)
	return greeting & ", " & name & "!"
end greet

on main()
	tell application "System Events"
		display dialog greet("World")
	end tell
end main

main()
