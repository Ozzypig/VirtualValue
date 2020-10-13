-- This goes in a Part, somewhere in your game.
-- Note: You also the 02-walkspeed.lua example for this to work.

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualNumberValue = require("VirtualValue:Types.Number")

local BONUS_WALK_SPEED = 8

local part = script.Parent

local debounce = false
local function onTouched(otherPart)
	if debounce then return end
	
	-- Check for WalkSpeedDV from WalkSpeed.lua
	local WalkSpeedDV = otherPart.Parent:FindFirstChild("WalkSpeedDV")
	if not WalkSpeedDV then return end

	-- Disable button
	debounce = true
	part.BrickColor = BrickColor.Black()

	-- Get the DynamicVirtualNumberValue from the other example
	local dvnv = require(WalkSpeedDV)

	-- Create and add a new VirtualNumberValue to it, adding the bonus
	local vnv = VirtualNumberValue.new(BONUS_WALK_SPEED)
	dvnv:addChild(vnv)
	wait(2)

	-- Allow button to be pressed again
	part.BrickColor = BrickColor.Red()
	debounce = false
	wait(6)

	-- Remove the effect and clean it up
	dvnv:removeChild(vnv)
	vnv:cleanup()
	vnv = nil
end

part.Touched:Connect(onTouched)
part.BrickColor = BrickColor.Red()
