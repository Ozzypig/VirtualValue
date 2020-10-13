-- This file shows basic usage of @{VirtualNumberValue}.

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualNumberValue = require("VirtualValue:Types.Number")

-- Create a VirtaulNumberValue with the given initial value
local vnv = VirtualNumberValue.new(0)

-- Set its value:
vnv:set(12)

-- Get the value:
print(vnv:get()) --> 12

-- Connect to onChange:
local function onValueChanged(newValue)
	print(newValue)
end
vnv.onChange:Connect(onValueChanged)

-- Or, better yet, use :listen(func)
vnv:listen(function (value)
	print(value)
end)

-- Bind it to something important!
local myTable = {}
vnv:bind(myTable.property)
print(myTable.proeprty) --> 12
