-- This file shows basic usage of a @{Client} using a @{VirtualNumberValue}.
-- Note: see also the 04-network-server.lua example

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualNumberValue = require("VirtualValue:Types.Number")

local vnv = VirtualNumberValue.new()
local cli = vnv:client(workspace:WaitForChild("MyVirtualValue"))

local function onValue(value)
	print("Value: " .. value)
end

cli.listen(onValue)
