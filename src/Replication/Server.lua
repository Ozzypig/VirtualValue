--[[- A server replicator for @{VirtualValue}.
A **Server** handles replication of a @{VirtualValue} to/from players with specific @{Permissions}. A @{Client} is used
to communicate with a server. The following protocols are used:

 * **Event**: Implemented using RemoteEvent. Represents some data that a server sends to one or more clients.
 * **Command**: Implemented using RemoteFunction. Represents a single query by a client who usually has some permission.

The different kinds of events and commands are described in @{Constants}. A server has two states:

  * **Closed**: Starting state. Server rejects all commands and emits no events.
  * **Open**: Server will respond to commands and emit events, such as when the VirtualValue changes.

On construction, a Server creates a **remotes container** using the @{Remotes} utility. This container can be
gotten using @{Server:getRemotesContainer|getRemotesContainer} and should be named/parented somewhere accessible
to clients. The remotes container should be passed to @{Client.new}. The container is destroyed when the server
is @{Server:cleanup|cleaned up}.

]]
-- @classmod Server
local RunService = game:GetService("RunService")

local Permissions = require(script.Parent.Permissions)
local Constants = require(script.Parent.Constants)
local Remotes = require(script.Parent.Remotes)

local Server = {}
Server.__index = Server

Server._commandHandlers = {}

function Server:registerCommandHandler(command, commandHandler)
	local handlers = self._commandHandlers
	assert(not handlers[command], "command handler already exists for command " .. command)
	handlers[command] = commandHandler
end

--- Create a new server that replicates the value contained in `virtualValue`
-- @tparam VirtualValue virtualValue The value to replicate
-- @tparam[opt] boolean allowRead Whether the Server should grant read permissions to all players
function Server.new(virtualValue, allowRead)
	assert(RunService:IsServer(), "Server.new can only be called on a server")
	local self = setmetatable({
		_open = false;
		_virtualValue = virtualValue;
		_permissions = allowRead and Permissions.readOnly() or Permissions.exclusive();
	}, Server)
	self._remotesContainer, self._remoteEvent, self._remoteFunction = Remotes.create()
	self._changeConn = virtualValue.onChange:connect(function (newValue)
		return self:_onVirtualValueChange(newValue)
	end)
	self._remoteFunction.OnServerInvoke = function (...)
		return self:_onRequestReceived(...)
	end
	self._listenerFunc = function (...)
		return self:_listener(...)
	end
	return self
end

--- Closes the server (if open) and releases all resources used
function Server:cleanup()
	if self:isOpen() then
		self:close()
	end
	self._remotesContainer:Destroy()
	self._remotesContainer = nil
	self._remoteEvent = nil
	self._remoteFunction = nil
	self._virtualValue = nil
	self._permissions:cleanup()
	self._permissions = nil
end

-- ======================== Server status

--- Returns the @{VirtualValue} whose value this server is replicating
-- @return @{VirtualValue}
function Server:getVirtualValue()
	return self._virtualValue
end

--- Returns an object which returns the remotes container in use by this server.
-- Should be passed to @{Client.new}.
-- @return The remotes container
function Server:getRemotesContainer()
	return self._remotesContainer
end

--- Convenience function for setting the remotes container parent and name properties
-- @param newParent The new parent object for the remotes container
-- @tparam[opt] string newName The name for the remotes container
function Server:setRemotesContainerParentName(newParent, newName)
	self._remotesContainer.Parent = newParent
	self._remotesContainer.Name = newName or self._remotesContainer.Name
end

--- Returns whether the server is open
function Server:isOpen()
	return self._open
end

--- Asserts whether the server @{Server:isOpen}
function Server:assertOpen()
	assert(self:isOpen(), "server is not open")
end

function Server:_setOpen(open)
	self._open = open
end

function Server:_listener(_newValue)
	self:replicateValue()
end

function Server:startListening()
	self._changeConn = self._virtualValue:listen(self._listenerFunc)
end

function Server:stopListening()
	self._changeConn:disconnect()
	self._changeConn = nil
end

--- Opens the server, immediately replicating the value
function Server:open()
	assert(not self:isOpen(), "already open")
	self:_setOpen(true)
	self:_sendDataToEveryone(Constants.Event.Opened)
	self:startListening()
end

--- Closes the server
function Server:close()
	assert(self:isOpen(), "not open")
	self:_setOpen(false)
	self:_sendDataToEveryone(Constants.Event.Closed)
	self:stopListening()
end

-- Returns the @{Permissions} object for this server
function Server:getPermissions()
	return self._permissions
end

-- ======================== Replication tools

--- Replicates the present values to everyone with "Read". Server must be open.
function Server:replicateValue()
	assert(self:isOpen())
	self:_sendData(Permissions.Kind.Read, Constants.Event.Value, self._virtualValue:serialize())
end

function Server:_onVirtualValueChange(_newValue)
	if self:isOpen() then
		self:replicateValue()
	end
end

function Server:_sendDataToEveryone(event, ...)
	self._remoteEvent:FireAllClients(event, ...)
end

function Server:_sendData(permission, event, ...)
	for _, player in pairs(self._permissions:getPermissionPlayerSet(permission):getPresent()) do
		self._remoteEvent:FireClient(player, event, ...)
	end
end

-- ======================== Command Handlers

function Server:_onGetPermissionsCommand(player)
	self:assertOpen()
	return self._permissions:collect(player)
end
Server:registerCommandHandler(Constants.Command.GetPermissions, Server._onGetPermissionsCommand)

function Server:_onGetCommand(player)
	self:assertOpen()
	self._permissions:assertRead(player)
	return self._virtualValue:serialize()
end
Server:registerCommandHandler(Constants.Command.Get, Server._onGetCommand)

function Server:_onSetCommand(player, payload)
	self:assertOpen()
	self._permissions:assertWrite(player)
	return self._virtualValue:deserialize(payload)
end
Server:registerCommandHandler(Constants.Command.Set, Server._onSetCommand)

function Server:_onRequestReceived(player, command, ...)
	return assert(self._commandHandlers[command], "command not recognized: " .. command)(self, player, ...)
end

return Server
