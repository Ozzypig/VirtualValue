--[[- Constants used in replication betwen @{Server} and @{Client}, mostly describing the protocol between them. 
The actual behavior of commands/events are implemented in these classes.

### Commands

Commands are listed in the `Constants.Commands` table, where the key/value is the name of the command. Commands may
require certain server @{Permissions} for clients to invoke them.

Note: on this page, they are described as functions (methods).

### Events

Events are listed in the `Constants.Events` table, where the key/value is the name of the event. Some events
will only replicate to clients with certain @{Permissions} on the server.

]]
-- @module Constants

local Constants = {}

Constants.Command = {
	--- Returns the permissions of the requesting client, as returned by @{Permissions:collect}. Requires no permission.
	-- @function GetPermissions
	GetPermissions = "GetPermissions";
	--- Returns the current value. Requires `Read` permission.
	-- @function Get
	Get = "Get";
	--- Sets the current value. Requires `Write` permission. May cause @{Constants.Value|Value} event to fire.
	-- @param newValue The new value
	-- @function Set
	Set = "Set";
}

Constants.Event = {
	--- Fires when the server @{Server:open|opens}, indicating that a @{Client} may make commands to it. Replicated
	-- to all clients.
	-- @event Opened
	Opened = "Opened";
	--- Fires when the server @{Server:close|closes}, indicating that no @{Client} may make commands to it, and events
	-- will not replicate (except @{Constants.Opened|Opened}). Replicated to all clients.
	-- @event Closed
	Closed = "Closed";
	--- Fires with the present value of the @{VirtualValue} replicated by the server. It may or may not have changed.
	-- Replicated to clients with `Read` permission.
	-- @param newValue The present value
	-- @event Value
	Value = "Value";
}

return Constants
