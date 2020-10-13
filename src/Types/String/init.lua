--- An implementation of @{VirtualValue} which stores a string.
-- @classmod VirtualStringValue
-- @see DynamicVirtualStringValue

local VirtualValue = require(script.Parent.Parent.VirtualValue)

return VirtualValue:implementForType("string")
