local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualNumberValue = require("VirtualValue:Types.Number")

local ServerTest = {}

ServerTest["test_Server"] = function ()
	local cueParent, cueName = workspace, "cue_test_Server"
	local containerParent, containerName = workspace, "test_Server"

	-- Used as a cue from the client to proceed with testing
	local cue = Instance.new("RemoteEvent")
	cue.Name = cueName
	cue.Parent = cueParent

	-- Working objects
	local vnv = VirtualNumberValue.new(1337)
	local srv = vnv:server(false)
	srv:setRemotesContainerParentName(containerParent, containerName)

	-- Cue 1
	local _, cueNo = cue.OnServerEvent:wait()
	assert(cueNo == 1, "cue 1 missed")

	-- Open server
	srv:open()
	
	-- Count from 0 to 100 by 5, setting the value
	for i = 0, 100, 25 do
		vnv:value(i)
	end

	-- Close server
	srv:close()

	-- The client should never see this value
	vnv:value(-1337)

	-- But, the client should see this one as soon as we reopen
	vnv:value(8675309)
	srv:open()

	-- Cue 2
	cue:FireAllClients(2)

	-- Cleanup
	srv:cleanup()
	srv = nil
	vnv:cleanup()
	vnv = nil
	cue:Destroy()
end

return ServerTest
