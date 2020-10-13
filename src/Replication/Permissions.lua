--[[- Contains permissions used by @{Server} to keep track of what player @{Client|Clients} can do.

### Permissions

  * `Read`: The player can read the value
  * `Write`: The player can write to the value

]]
-- @classmod Permissions

local PlayerSet = require(script.Parent.PlayerSet)

local Permissions = {}
Permissions.__index = Permissions

Permissions.Kind = {
	Read = "Read";
	Write = "Write";
}

--- Constructs a new Permissions wherein no player has any permission
function Permissions.exclusive()
	local self = Permissions.new()
	self._read:setMode(PlayerSet.Mode.Allow)
	self._read:reset()
	self._write:setMode(PlayerSet.Mode.Allow)
	self._write:reset()
	return self
end

--- Constructs a new Permissions wherein every player has all permissions
function Permissions.inclusive()
	local self = Permissions.new()
	self._read:setMode(PlayerSet.Mode.Deny)
	self._read:reset()
	self._write:setMode(PlayerSet.Mode.Deny)
	self._write:reset()
	return self
end

--- Constructs a new Permissions wherein all players can read the value, and none can write
function Permissions.readOnly()
	local self = Permissions.new()
	self._read:setMode(PlayerSet.Mode.Deny)
	self._read:reset()
	self._write:setMode(PlayerSet.Mode.Allow)
	self._write:reset()
	return self
end

--- Construct a new Permissions object wherein no player has any permissions
-- @constructor
function Permissions.new()
	local self = setmetatable({
		_read = PlayerSet.nobody();
		_write = PlayerSet.nobody();
	}, Permissions)
	return self
end

--- Release all resources used
function Permissions:cleanup()
	self._read:cleanup()
	self._read = nil
	self._write:cleanup()
	self._write = nil
end

--- Retrieves the @{PlayerSet} used for the given permission
-- @treturn PlayerSet The set for the given permission
function Permissions:getPermissionPlayerSet(permission)
	assert(Permissions.Kind[permission], "no such permission: " .. permission)
	if permission == Permissions.Kind.Read then
		return self._read
	elseif permission == Permissions.Kind.Write then
		return self._write
	end
end

--- Queries whether a player has a permission
-- @param player The player to query
-- @param permission The permission to query
-- @treturn boolean
function Permissions:hasPermission(player, permission)
	return self:getPermissionPlayerSet(permission):contains(player)
end

--- Asserts that the given player @{Permissions:hasPermission|has} the given permission
function Permissions:assertPermission(player, permission)
	assert(self:hasPermission(player, permission), "missing permission: " .. permission)
end

--- Returns whether the given player @{Permissions:hasPermission|has} `Read` permission
-- @param player The player to query
-- @treturn boolean
function Permissions:hasRead(player)
	return self:hasPermission(player, Permissions.Kind.Read)
end

--- Asserts that the given player @{Permissions:hasPermission|has} `Read` permissions
-- @param player The player to query
function Permissions:assertRead(player)
	self:assertPermission(player, Permissions.Kind.Read)
end

--- Returns whether the given player @{Permissions:hasPermission|has} `Write` permission
-- @param player The player to query
-- @treturn boolean
function Permissions:hasWrite(player)
	return self:hasPermission(player, Permissions.Kind.Write)
end

--- Asserts that the given player @{Permissions:hasPermission|has} `Write` permissions
-- @param player The player to query
function Permissions:assertWrite(player)
	self:assertPermission(player, Permissions.Kind.WRite)
end

--- For a given player, checks if they @{Permissions:hasPermission|have} each permission
-- @param player The player whose permissions are queried
-- @treturn table A dictionary where `[permission] = true/false`
function Permissions:collect(player)
	local perms = {}
	for _, perm in pairs(Permissions.Kind) do
		perms[perm] = self:hasPermission(player, perm)
	end
	return perms
end

return Permissions
