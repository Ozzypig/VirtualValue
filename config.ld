-- Meta
project = "VirtualValue"
description = "A flavorful alternative to ValueBase objects in Roblox"
title = "VirtualValue Documentation"

-- File system
format = "markdown"
readme = "README.md"
file = {
	"src"
}
dir = "site"
topics = "topics"
examples = "examples"

--
use_markdown_titles = true
no_summary = false
no_space_before_args = true
not_luadoc = true

-- LDoc extensions
new_type("event", "Events")
new_type("staticfield", "Static Fields", false)
new_type("staticfunction", "Static Functions")
new_type("constructor", "Constructors", false, "function")
alias("property", "field")
alias("subclass", "see")
alias("private", "local")

custom_tags = {
	{'remark', title='Remark', hidden=false};
	{'superclass', title='Superclass', hidden=false};
	{'abstract', title='Abstract', hidden=false};
}
