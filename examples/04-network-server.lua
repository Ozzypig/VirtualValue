-- This file shows basic usage of a @{Server} using a @{VirtualNumberValue}.
-- Note: see also the 04-network-client.lua example

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualNumberValue = require("VirtualValue:Types.Number")

-- Create a VirtaulNumberValue
local vnv = VirtualNumberValue.new(0)

-- Create the server (all permissions enabled) and open it
local srv = vnv:server(false)

-- The "remotes container" is used by the client - let's put it somewhere easy
srv:setRemotesContainerParentName(workspace, "MyVirtualValue")

-- Open the server so clients can start receiving the value
srv:open()
vnv:set(1337) --> this is replicated to all clients

-- Close the server, make a bunch of changes (which won't replicate),
-- then re-open it so the current value replicates.
srv:close()
-- ...
vnv:set(1337)
-- ...
srv:open()
