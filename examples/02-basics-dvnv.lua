-- This file shows basic usage of @{DynamicVirtualNumberValue}.

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualNumberValue = require("VirtualValue:Types.Number")
local DynamicVirtualNumberValue = require("VirtualValue:Types.Number.Dynamic")

-- Create a DynamicVirtaulNumberValue that stacks additively, with base value 0
local dvnv = DynamicVirtualNumberValue.new("Add", 5)

-- Get/set its base value:
print(dvnv:getBase()) --> 5
dvnv:set(0)

-- Create some @{VirtualNumberValue} to @{DynamicVirtualValue:addChild|add} as children
local vnv = VirtualNumberValue.new(5)
local vnv2 = VirtualNumberValue.new(4)
dvnv:addChild(vnv)
dvnv:addChild(vnv2)

-- Get the current value (this causes a recalculation)
print(dvnv:get()) --> 9, because 4 + 5

-- Use listen to listen for ANY changes in the value:
dvnv:listen(function (value)
	print(value)
end)

-- Removing a child causes a change in value,
-- as now only the child with value "5" remains
dvnv:removeChild(vnv2) --> 5
