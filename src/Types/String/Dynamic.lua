--[[- An implementation of @{DynamicVirtualValue} which stores a string.

### Stack modes

  * `Concat`: Returns `lhs .. rhs`, default base value is `""` (empty string)
  * `ConcatReverse`: Returns `rhs .. lhs`, default base value is `""` (empty string)

### Usage

```lua
local dvnv = DynamicVirtualStringValue.new("Concat")
dvnv:newChild("Hello")
dvnv:newChild("World")
dvnv:newChild("Spam")
print(dvnv:get()) --> "Hello" .. "World" .. "Spam" => "HelloWorldSpam"
local dvnv2 = DynamicVirtualNumberValue.new("ConcatReverse", "Foo")
dvnv2:newChild("Bar")
print(dvnv2:get()) --> "Bar" .. "Foo" => "BarFoo"
dvnv:addChild(dvnv2)
print(dvnv:get()) --> "Hello" .. "World" .. "Spam" .. ("Bar" .. "Foo") => "HelloWorldSpamBarFoo"
```

]]
-- @classmod DynamicVirtualStringValue
-- @see VirtualStringValue

local DynamicVirtualValue = require(script.Parent.Parent.Parent.DynamicVirtualValue)

local DynamicVirtualNumberValueImpl = DynamicVirtualValue:implementForType("string", {
	Concat = function (lhs, rhs)
		return lhs .. rhs
	end;
	ConcatReverse = function (lhs, rhs)
		return rhs .. lhs
	end;
}, {
	Concat = "";
	ConcatReverse = "";
})
DynamicVirtualNumberValueImpl.VirtualValueClass = require(script.Parent)

return DynamicVirtualNumberValueImpl
