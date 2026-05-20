(*
  Showcase of constructs the extension highlights.
  Useful when manually smoke-testing changes to highlights.scm,
  indents.scm, or outline.scm.
*)

use AppleScript version "2.4"
use scripting additions
use framework "Foundation"
use Safari : application "Safari"

property |the user's name| : "Jane"
global counter
local tmp

-- Numbers, booleans, missing value
set n to 42
set pi_val to 3.14159
set yes_flag to true
set nothing to missing value

-- Lists, records, strings with escapes
set items_list to {1, 2, 3, "four", "five with \"quotes\""}
set rec to {name:"Jane", age:30}

-- Date literal and raw data
set d to date "Saturday, January 1, 2026 at 12:00:00 PM"
set raw to «class fold»

-- Pipe-delimited identifiers
set |list of names| to {"Alice", "Bob"}

-- Compound names with line continuation
set p to path to ¬
	home folder

-- Tell block + try/error
tell application "Finder"
	try
		set selected to selection
		if (count of selected) is 0 then
			display dialog "Nothing selected"
		else
			repeat with itm in selected
				log itm
			end repeat
		end if
	on error err_msg number err_num
		display dialog "Error " & err_num & ": " & err_msg
	end try
end tell

-- One-line if forms
if n > 0 then return n
if n < 0 then say "negative"

-- Handler with labeled (given) parameters
on shout given message:m, repeat_count:r
	repeat r times
		say m
	end repeat
end shout

-- ObjC-style handler with selector syntax
on splitString:s byDelim:d
	set NSStr to current application's NSString's stringWithString:s
	set arr to NSStr's componentsSeparatedByString:d
	return arr as list
end splitString:byDelim:

-- Script object with parent
script Counter
	property value : 0
	on increment()
		set value to value + 1
		return value
	end increment
end script

-- Considering/ignoring
considering case
	if "A" is "a" then log "case-sensitive"
end considering

-- with timeout
with timeout of 30 seconds
	tell application "Mail" to count of messages
end timeout

-- do shell script — bash is injected here
do shell script "echo 'shell command' | tr a-z A-Z"

-- run script — AppleScript or JXA based on content
run script "display dialog \"injected applescript\""
run script "
  function run() {
    return 'injected JXA';
  }
"
