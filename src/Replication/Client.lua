--[[- A client replicator for a @{VirtualValue}.

]]
-- @classmod Client

local RunService = game:GetService("RunService")

local Remotes = require(script.Parent.Remotes)
local Constants = require(script.Parent.Constants)

local Client = {}
Client.__index = Client

Client._eventHandlers = {}

function Client:registerEventHandler(event, eventHandler)
	local handlers = self._eventHandlers
	assert(not handlers[event], "event handler already exists for event " .. event)
	handlers[event] = eventHandler
end

--- Constructs a new client to handle replication
-- @param virtualValue The @{VirtualValue} to wrap
-- @param remotes The remotes container as returned by @{Server:getRemotesContainer}
function Client.new(virtualValue, remotes)
	assert(RunService:IsClient(), "Client.new can only be called on a client")
	local self = setmetatable({
		_virtualValue = virtualValue;
		_remotes = assert(typeof(remotes) == "Instance" and remotes, "Remotes instance expected");
		_remoteEvent = nil;
		_remoteFunction = nil;
		_clientEventConn = nil;
		_open = false;
	}, Client)
	self._remoteEvent, self._remoteFunction = Remotes.get(self._remotes)
	self._clientEventConn = self._remoteEvent.OnClientEvent:Connect(function (...)
		return self:_onDataReceived(...)
	end)

	return self
end

--- Releases all resources used
function Client:cleanup()
	self._clientEventConn:disconnect()
	self._clientEventConn = nil
	self._virtualValue = nil
	self._remotes = nil
	self._remoteEvent = nil
	self._remoteFunction = nil
	self._open = false
end

function Client:replicate()
	return self:_sendCommand(Constants.Command.Set, self._virtualValue:serialize())
end

function Client:isOpen()
	return self._open
end

function Client:_sendCommand(command, ...)
	return self._remoteFunction:InvokeServer(command, ...)
end

function Client:_onDataReceived(event, ...)
	print("_onDataReceived", event, ...)
	return assert(self._eventHandlers[event], "no event handler for event: " .. event)(self, ...)
end

function Client:_onEventValue(payload)
	self._virtualValue:deserialize(payload)
end
Client:registerEventHandler(Constants.Event.Value, Client._onEventValue)

function Client:_onEventOpened()
	self._open = true
end
Client:registerEventHandler(Constants.Event.Opened, Client._onEventOpened)

function Client:_onEventClosed()
	self._open = false
end
Client:registerEventHandler(Constants.Event.Closed, Client._onEventClosed)

return Client
