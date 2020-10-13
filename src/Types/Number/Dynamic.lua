--[[- An implementation of @{DynamicVirtualValue} which stores a number.

### Stack modes

  * `Add`: Returns `lhs + rhs`, default base value is `0`
  * `Mult`: Returns `lhs * rhs`, default base value is `1`

### Usage

```lua
local dvnv = DynamicVirtualNumberValue.new("Add")
dvnv:newChild(1)
dvnv:newChild(2)
dvnv:newChild(3)
print(dvnv:get()) --> 0+1+2+3=6
local dvnv2 = DynamicVirtualNumberValue.new("Mult", 4)
dvnv2:newChild(5)
print(dvnv2:get()) --> 4*5=20
dvnv:addChild(dvnv2)
print(dvnv:get()) --> 0+1+2+3+(4*5)=26
```

]]
-- @classmod DynamicVirtualNumberValue
-- @see VirtualNumberValue

local DynamicVirtualValue = require(script.Parent.Parent.Parent.DynamicVirtualValue)

local DynamicVirtualNumberValueImpl = DynamicVirtualValue:implementForType("number", {
	Add = function (lhs, rhs)
		return lhs + rhs
	end;
	Mult = function (lhs, rhs)
		return lhs * rhs
	end;
}, {
	Add = 0;
	Mult = 1;
})
DynamicVirtualNumberValueImpl.VirtualValueClass = require(script.Parent)

return DynamicVirtualNumberValueImpl
