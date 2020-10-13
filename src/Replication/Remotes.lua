--- Helper module for creating a @{Server}'s remotes container, and finding the RemoteEvent/RemoteFunction within it.
-- @module Remotes

local Remotes = {}

--- On server, build and return an object structure that includes RemoteEvent/RemoteFunction, which are also returned
function Remotes.create()
	local remoteEvent = Instance.new("RemoteEvent")
	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Parent = remoteEvent
	return remoteEvent, remoteEvent, remoteFunction
end

-- Given a structure built by `Remotes.create`, return the RemoteEvent and RemoteFunction within it
function Remotes.get(object)
	return object, object:FindFirstChild("RemoteFunction")
end

return Remotes
