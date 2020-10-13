--[[- An implementation of @{DynamicVirtualValue} which stores a boolean.

### Stack modes

  * `And`: Returns `lhs and rhs`, default base value is `true`
  * `Or`: Returns `lhs or rhs`, default base value is `false`

### Usage

```lua
local dvbv = DynamicVirtualBoolValue.new("Or")
dvbv:newChild(false)
dvbv:newChild(true)
dvbv:newChild(false)
print(dvbv:get()) --> true
```

]]
-- @classmod DynamicVirtualBoolValue
-- @see VirtualBoolValue

local DynamicVirtualValue = require(script.Parent.Parent.Parent.DynamicVirtualValue)

local DynamicVirtualBoolValueImpl = DynamicVirtualValue:implementForType("boolean", {
	And = function (lhs, rhs)
		return lhs and rhs
	end;
	Or = function (lhs, rhs)
		return lhs or rhs
	end;
}, {
	And = true;
	Or = false;
})
DynamicVirtualBoolValueImpl.VirtualValueClass = require(script.Parent)

return DynamicVirtualBoolValueImpl
