--- An implementation of @{VirtualValue} which stores a boolean.
-- @classmod VirtualBoolValue
-- @see DynamicVirtualBoolValue

local VirtualValue = require(script.Parent.Parent.VirtualValue)

return VirtualValue:implementForType("boolean")
