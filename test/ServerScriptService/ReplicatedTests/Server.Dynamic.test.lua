local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualNumberValue = require("VirtualValue:Types.Number")
local DynamicVirtualNumberValue = require("VirtualValue:Types.Number.Dynamic")

local ServerDynamicTest = {}

ServerDynamicTest["test_Server.Dynamic"] = function ()
	local cueParent, cueName = workspace, "cue_test_Server.Dynamic"
	local containerParent, containerName = workspace, "test_Server.Dynamic"

	-- Used as a cue from the client to proceed with testing
	local cue = Instance.new("RemoteEvent")
	cue.Name = cueName
	cue.Parent = cueParent

	-- Working objects
	local dvnv = DynamicVirtualNumberValue.new("Add", 1337)
	local srv = dvnv:server(false)
	srv:setRemotesContainerParentName(containerParent, containerName)

	-- Cue 1: the client is ready to test
	local _, cueNo = cue.OnServerEvent:wait()
	assert(cueNo == 1, "cue 1 missed")

	-- Open server
	srv:open()                   --> 1337

	-- Make some changes
	dvnv:value(3)                -->  3
	local vnv = VirtualNumberValue.new(5)
	dvnv:addChild(vnv)           -->  8 = 3+5
	local vnv2 = VirtualNumberValue.new(7)
	dvnv:addChild(vnv2)          --> 15 = 3+5+7
	dvnv:removeChild(vnv)        --> 10 = 3+7
	dvnv:removeChild(vnv2)       -->  3 = 3

	-- Close server
	srv:close()

	-- The client should never see this value
	dvnv:value(-1337)

	-- But, the client should see this one as soon as we reopen
	dvnv:value(8675309)
	srv:open()                   --> 8675309

	-- Cue 2: server is done testing, client may clean up
	cue:FireAllClients(2)

	-- Cleanup
	srv:cleanup()
	srv = nil
	dvnv:cleanup()
	dvnv = nil
	vnv:cleanup()
	vnv = nil
	vnv2:cleanup()
	vnv2 = nil
	cue:Destroy()
end

return ServerDynamicTest
