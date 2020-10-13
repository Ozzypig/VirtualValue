local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualNumberValue = require("VirtualValue:Types.Number")
local VirtualValueClient = require("VirtualValue:Replication.Client")

local ClientTest = {}

ClientTest["test_Client"] = function ()
	local cueParent, cueName = workspace, "cue_test_Server"
	local containerParent, containerName = workspace, "test_Server"

	local cue = cueParent:WaitForChild(cueName)

	-- Some objects to work with
	local vnv = VirtualNumberValue.new(1337)

	-- The VirtualNumberValue transition between these values:
	local expectedValues = {1337, 0, 25, 50, 75, 100, 8675309}

	-- Check each value as it is set on the VirtualNumberValue
	local i = 0
	local conn = vnv:listen(function (value)
		print("client value: " .. value)
		i = i + 1
		assert(value == expectedValues[i], ("value %d was expected to be %d, was actually %d"):format(
			i, expectedValues[i], value
		))
	end)

	-- Create the client!
	local cli = VirtualValueClient.new(vnv, containerParent:WaitForChild(containerName))
	
	-- Cue 1
	cue:FireServer(1)

	-- Cue 2
	assert(cue.OnClientEvent:wait() == 2, "cue missed")

	-- Cleanup
	conn:disconnect()
	conn = nil
	vnv:cleanup()
	vnv = nil
	cli:cleanup()
	cli = nil
	cue = nil
end

ClientTest["test_Client.Dynamic"] = function ()
	local cueParent, cueName = workspace, "cue_test_Server.Dynamic"
	local containerParent, containerName = workspace, "test_Server.Dynamic"

	local cue = cueParent:WaitForChild(cueName)

	-- Some objects to work with
	local vnv = VirtualNumberValue.new(1337)

	-- The VirtualNumberValue transition between these values:
	local expectedValues = {1337, 3, 8, 15, 10, 3, 8675309}

	-- Check each value as it is set on the VirtualNumberValue
	local i = 0
	local conn = vnv:listen(function (value)
		print("client value: " .. value)
		i = i + 1
		assert(value == expectedValues[i], ("value %d was expected to be %d, was actually %d"):format(
			i, expectedValues[i], value
		))
	end)

	-- Create the client!
	local cli = VirtualValueClient.new(vnv, containerParent:WaitForChild(containerName))
	
	-- Cue 1: indicate that the client is ready
	cue:FireServer(1)

	-- Cue 2: server indicates it is done running tests
	assert(cue.OnClientEvent:wait() == 2, "cue missed")

	-- Cleanup
	conn:disconnect()
	conn = nil
	vnv:cleanup()
	vnv = nil
	cli:cleanup()
	cli = nil
	cue = nil
end

return ClientTest
