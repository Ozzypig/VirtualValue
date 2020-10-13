--[[- (Abstract) A container for a single value.

A **VirtualValue** (or *VV* for short) has a single contained value. This value is initially nil, although implementations
should set a sensible default (`0`, `false`, `""`, etc). It has useful tools which allow you to observe and manipulate the value:

  * @{VirtualValue:set|set(value)}, which sets the currently contained value
  * @{VirtualValue:get|get}, which returns the value
  * @{VirtualValue:value|value([newValue])}, which can both @{VirtualValue:set|set} and @{VirtualValue:get|get} the value
  * @{VirtualValue:listen|listen(func)}, which calls a given function with the contained value and every time it changes
  * @{VirtualValue:bind|bind(object, property)}, which sets a key of a table with the contained value and every time it changes

Additionally, the @{VirtualValue.onChange|onChange(newValue)} event fires immediately after the value is @{VirtualValue:set|set}
though any means.

### Replication

Server-side replication of a VirtualValue is easily implemented through a @{Server}, constructable through the
@{VirtualValue:server|server} method. On the client, use the @{VirtualValue:client|client} method and provide the
@{Server:getRemotesContainer|remotes container}. Finally, @{Server:open|open} the server to begin replication.
You can set up fine-grain replication rules within the @{Permissions} of the Server.

### Implementations:

  * @{VirtualNumberValue}, for number
  * @{VirtualStringValue}, for string
  * @{VirtualBoolValue}, for boolean

### See also:

  * @{DynamicVirtualValue}, an abstract subclass which can add VirtualValue as children to stack their values

]]
-- @classmod VirtualValue
-- @abstract

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local Maid = require("Maid")
local Event = require("Event")

local Server = require(script.Parent.Replication.Server)
local Client = require(script.Parent.Replication.Client)

local VirtualValue = {}
VirtualValue.__index = VirtualValue
VirtualValue.ServerClass = Server
VirtualValue.ClientClass = Client

--- Creates a subclass wherein the given `expectedType` is passed to @{VirtualValue.new} and the subclass constructor take an optional initial value.
-- @staticfunction VirtualValue:implementForType
-- @private
function VirtualValue.implementForType(cls, expectedType)
	local VirtualValueClass = setmetatable({}, cls)
	VirtualValueClass.__index = VirtualValueClass

	function VirtualValueClass.new(initValue)
		local self = setmetatable(cls.new(expectedType), VirtualValueClass)
		if typeof(initValue) ~= "nil" then 
			self:set(initValue)
		end
		return self
	end

	return VirtualValueClass
end

function VirtualValue._convertExpectedTypesToSet(expectedType)
	local expectedTypesSet = {}
	if typeof(expectedType) == "table" then
		for _i, v in pairs(expectedType) do
			expectedTypesSet[v] = true
		end
	elseif typeof(expectedType) == "string" then
		expectedTypesSet[expectedType] = true
	else
		error(("Unknown type for expectedType: %s"):format(typeof(expectedType)))
	end
	return expectedTypesSet
end

--- Constructs a new VirtualValue which contains a certain `expectedType`
-- @constructor
-- @tparam string expectedType expected type (or table of expected types) to be contained
function VirtualValue.new(expectedType)
	local self = setmetatable({
		_value = nil;
		_expectedTypesSet = VirtualValue._convertExpectedTypesToSet(expectedType);

		--- Fires when the contained value changes
		-- @event onChange
		-- @param newValue The new contained value
		onChange = Event.new();

		_maid = Maid.new();
	}, VirtualValue)
	self._maid:addTask(self.onChange)
	self.onChanged = self.onChange
	return self
end

--- Returns the current value passed to `tostring`
--@treturn string The current value as a string
function VirtualValue:__tostring()
	return tostring(self._value)
end

--- Releases all resources used by this VirtualValue
function VirtualValue:cleanup()
	if self._maid then
		self._maid:cleanup()
		self._maid = nil
	end
	self.onChange = nil
end

--- Returns whether the given value is of the expected type of this value
-- @param value A value to check
-- @treturn boolean Whether the value is of the expected type
-- @private
function VirtualValue:_isExpectedType(value)
	return self._expectedTypesSet[typeof(value)]
end

--- Sets the contained value; if different than current, fires `onChange`
-- @param value The value to store
function VirtualValue:set(value)
	assert(self:_isExpectedType(value), ("incorrect type: %s"):format(typeof(value)))
	if value == self._value then return end
	self._value = value
	self.onChange:fire(self:get())
end

--- Gets the contained value
-- @return The contained value
function VirtualValue:get()
	return self._value
end

--- Set/get the contained value
-- @param[opt] newValue The new value to set, or nil to keep the current value
-- @return The contained value
function VirtualValue:value(newValue)
	if typeof(newValue) ~= "nil" then
		self:set(newValue)
	end
	return self:get()
end

--- Call a function with the contained value, then again every time the contained value @{VirtualValue.onChange|changes}
-- @tparam function func The listener function
-- @treturn Connection When disconnected, `func` from being called when the value changes
function VirtualValue:listen(func)
	local function speak()
		func(self:get())
	end
	coroutine.wrap(speak)()
	return self.onChange:connect(speak)
end

--- Set `object[property]` to the currently contained value, then again every time the contained value @{VirtualValue.onChange|changes}
-- @param object A table, userdata, etc which can accept `[property] = ...`
-- @tparam string property The index on `object` to set
-- @treturn Connection When disconnected, stops `func` from being called when the value changes
function VirtualValue:bind(object, property)
	local function update()
		object[property] = self:get()
	end
	update()
	return self.onChange:connect(update)
end

--- Returns the class used by @{VirtualValue:server}
-- @return The Server class
function VirtualValue:getServerClass()
	return self.ServerClass
end

--- Constructs a @{Server} to replicate the contained value to various clients
-- @param ... Passed to @{Server.new}
-- @treturn Server The newly constructed server
function VirtualValue:server(...)
	return self:getServerClass().new(self, ...)
end

--- Constructs a @{Client} to replicate the contained value to/from the server
-- @param remotes The remotes container as returned by @{Server:getRemotesContainer}
-- @treturn Client
function VirtualValue:client(remotes)
	return self:getClientClass().new(self, remotes)
end

--- Convert the contained value into a payload that can be sent through Roblox's serialization used by BindableFunction, RemoteFunction, etc.
-- This default implementation sends the data unchanged; custom types will need custom serilization.
-- @return The data payload
function VirtualValue:serialize()
	return self:get()
end

--- Set the contained value to the provided payload from @{VirtualValue:serialize|serialize}
-- @param payload The data payload
function VirtualValue:deserialize(payload)
	self:set(payload)
end

return VirtualValue
