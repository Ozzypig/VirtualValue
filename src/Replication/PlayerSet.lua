--[[- Used by @{Permissions} to keep track of an inclusive or exclusive set of players.

A **PlayerSet** contains a set of Player objects (the **individuals**), and uses one of two modes: `Allow` and `Deny`. These determine
which players are part of the set.

  * `Allow`: Only individuals are included in the set
  * `Deny`: Everyone except individuals are included set

]]
-- @classmod PlayerSet

local Players = game:GetService("Players")

local PlayerSet = {}
PlayerSet.__index = PlayerSet

PlayerSet.Mode = {
	Allow = "Allow";
	Deny = "Deny";
}

--- Constructs a new set with mode `Allow` that contains no players
function PlayerSet.nobody()
	return PlayerSet.new(PlayerSet.Mode.Allow, {})
end

--- Constructs a new set with mode `Deny` that contains all players
function PlayerSet.everybody()
	return PlayerSet.new(PlayerSet.Mode.Deny, {})
end

--- Constructs a new set with given mode and array of players to use as individuals
-- @param mode Either `Allow` or `Deny`
-- @param[opt] players An array of players to include/exclude based on `mode`
function PlayerSet.new(mode, players)
	local self = setmetatable({
		mode = PlayerSet.Mode.Allow;
		players = {};
	}, PlayerSet)
	self:setMode(mode)
	if players then
		if self.mode == PlayerSet.Mode.Allow then
			self:includeAll(players)
		elseif self.mode == PlayerSet.Mode.Deny then
			self:excludeAll(players)
		end
	end
	return self
end

--- Releases all used resources
function PlayerSet:cleanup()
	self.mode = nil
	self.players = nil
end

function PlayerSet:_isPlayer(player)
	return typeof(player) == "Instance" and player:IsA("Player")
end

--- Change the inclusion/exclusion mode of the set.
-- By changing this, you effectively invert the player set.
-- @param newMode Either `Allow` or `Deny`
function PlayerSet:setMode(newMode)
	self.mode = assert(PlayerSet.Mode[newMode] and newMode, "invalid mode: " .. newMode)
end

--- Returns whether the given player is in the set
-- @param player A player to query
-- @treturn boolean Whether the player is contained in the set
function PlayerSet:contains(player)
	assert(self:_isPlayer(player))
	if self.mode == PlayerSet.Mode.Allow then
		return type(self.players[player]) ~= "nil"
	elseif self.mode == PlayerSet.Mode.Deny then
		return type(self.players[player]) == "nil"
	end
end

--- For `Allow` sets, includes the given player as contained with the set
-- @param player The player to include
function PlayerSet:include(player)
	assert(self.mode == PlayerSet.Mode.Allow, "PlayerSet.mode is not \"Allow\"")
	assert(self:_isPlayer(player))
	self.players[player] = true
end

--- For `Allow` sets, @{PlayerSet:include|includes} all the players given in the array as contained with the set
-- @param players Array of players to include
function PlayerSet:includeAll(players)
	for _i, player in ipairs(players) do
		self:inclue(player)
	end
end

--- For `Deny` sets, excludes the given player as not contained with the set
-- @param player The player to include
function PlayerSet:exclude(player)
	assert(self.mode == PlayerSet.Mode.Allow, "PlayerSet.mode is not \"Deny\"")
	assert(self:_isPlayer(player))
	self.players[player] = true
end

--- For `Deny` sets, @{PlayerSet:exclude|excludes} all the players given in the array as not contained with the set
-- @param players Array of players to include
function PlayerSet:excludeAll(players)
	for _i, player in ipairs(players) do
		self:exclude(player)
	end
end

--- Resets the individuals on the set so that no players are included/excluded
function PlayerSet:reset()
	for player, _ in pairs(self.players) do
		self.players[player] = nil
	end
end

--- Copies the configuration of another PlayerSet
-- @tparam PlayerSet otherPlayerSet The set to copy configuration from
function PlayerSet:copyFrom(otherPlayerSet)
	self.mode = otherPlayerSet.mode
	self:reset()
	for player, v in pairs(otherPlayerSet.players) do
		self.players[player] = v
	end
end

--- Returns an array of players currently connected to the server who are @{PlayerSet:contains|contained} in the set
-- @return An array of players
function PlayerSet:getPresent()
	local players = {}
	for _, player in pairs(Players:GetPlayers()) do
		if self:contains(player) then
			table.insert(players, player)
		end
	end
	return players
end

return PlayerSet
