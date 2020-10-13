--- An implementation of @{VirtualValue} which stores a number.
-- @classmod VirtualNumberValue
-- @see DynamicVirtualNumberValue

local VirtualValue = require(script.Parent.Parent.VirtualValue)

return VirtualValue:implementForType("number")
