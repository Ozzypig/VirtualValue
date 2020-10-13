-- This goes in a ModuleScript named "WalkSpeedDV" within StarterPlayer.StarterCharacterScripts:
-- Note: Also add the 02-walkspeedboost.lua example!

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local DynamicVirtualNumberValue = require("VirtualValue:Types.Number.Dynamic")

local human = script.Parent:FindFirstChildOfClass("Humanoid")

-- Create a DynamicVirtualNumberValue and bind it to the Humanoid's WalkSpeed
local dvnv = DynamicVirtualNumberValue.new("Add", human.WalkSpeed)
dvnv:bind(human, "WalkSpeed")
return dvnv
