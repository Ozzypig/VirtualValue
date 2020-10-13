--- Invokes TestRunner with the tests in ServerTests

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TestRunner = require(ReplicatedStorage:WaitForChild("TestRunner"))

local VirtualValueTest = ServerScriptService:WaitForChild("VirtualValueTest")

local function main()
	-- Run tests not related to replication first
	TestRunner.gather(VirtualValueTest:WaitForChild("NonReplicatedTests")):runAndReport()

	-- Wait for first player to arrive...
	while #Players:GetPlayers() == 0 do
		Players.PlayerAdded:wait()
	end
	-- Then run tests related to replication
	TestRunner.gather(VirtualValueTest:WaitForChild("ReplicatedTests")):runAndReport()
end
main()
