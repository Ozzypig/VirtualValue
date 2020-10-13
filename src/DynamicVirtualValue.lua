--[[- (Abstract) A container a base value and many VirtualValues which are "stacked" together.

A **DynamicVirtualValue** (or *DVV* for short) is a @{VirtualValue} which can also have child VirtualValues
@{DynamicVirtualValue:addChild|added} to it. Like a plain VirtualValue, a DVV still contains a value, which is
called the **base value** (retrieved using @{DynamicVirtualValue:getBase|getBase}), in addition to its children.

When you @{DynamicVirtualValue:get|get} the value of a DVV, you get the **stacked value** instead of the base
value. This is calculated from the base value and values of the children using the @{DynamicVirtualValue:stack|stack}
method. The calculation is as follows:

```
stacked_value = base_value + value1 + value2 + ... + valueN
```

Where `valueN` indicates the value @{VirtualValue:get|gotten} from each child, and `+` represents the operation defined
by the @{DynamicVirtualValue:stack|stack} method. The operations are completed left-to-right. This is an O(n) calculation.

#### Children and Nesting

  * Any VirtualValue can be added as a child, including other DVVs. During a stacked value calculation a DVV calls `get`
on its children. For child DVVs, this returns their stacked value (not their base value).
  * A VirtualValue can also be added as a child to multiple DVVs. In other words, a VirtaulValue may have any number of
  parents.
  * Beware of disasterous non-halting infinite loops when two DVVs are decendants of each other.

#### Caching and "Dirtiness"

When the stacked value is calculated, it is **cached** so that future calls skip recalculation (providing a runtime
of O(1)). However, if the DVV's base value changes or if a child is added/removed/changed, then the DVV is considered
**dirty**. The next time the value is @{DynamicVirtualValue:get|gotten}, it will be recalculated. Furthermore, a
DVV is also dirtied whenever a child DVV is dirtied.

#### Runtime Bewares

Understanding when the DVV is dirtied is important, as this can affect runtime. To avoid
excessive recalculations, you should adjust a DVV's base value and children *before* you
@{DynamicVirtualValue:get|get}, @{DynamicVirtualValue:listen|listen} or @{DynamicVirtualValue:bind|bind},
as these methods recalculate the stacked value; in the case of listen and bind, these recalculate also
when DVV is @{DynamicVirtualValue.onDirtied|dirtied}). If you're making a lot of modifications
to the base value or child values, disconnect the connections these functions return temporarily. When you
are done making changes, re-listen or re-bind.

```lua
local dvnv = DynamicVirtualNumberValue.new("Add", 0)
local conn = dvnv:listen(myFunction)
-- At this point, when any dirty-ing change is made,
-- the value is recalculated (an O(n) operation)
-- To stop this, disconnect and forget about the old connection:
conn:disconnect()
conn = nil
-- Now, we can make changes without causing recalculations:
dvnv:set(8)
dvnv:addChild(VirtualNumberValue.new(5))
dvnv:removeChild(someOtherChild)
-- Re-listen once finished; this recalculates then calls myFunction:
conn = dvnv:listen(myFunction) --> calls myFunction(13)
```

### Implementations:

  * @{DynamicVirtualNumberValue}, for number
  * @{DynamicVirtualStringValue}, for string
  * @{DynamicVirtualBoolValue}, for bool

]]
-- @classmod DynamicVirtualValue
-- @abstract
-- @see VirtualValue

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local Event = require("Event")

local VirtualValue = require(script.Parent.VirtualValue)

local DynamicVirtualValue = setmetatable({}, {__index = VirtualValue})
DynamicVirtualValue.__index = DynamicVirtualValue

DynamicVirtualValue.VirtualValueClass = nil
DynamicVirtualValue.defaultStackModes = {
	First = function (lhs, _rhs)
		return lhs 
	end;
	Last = function (_lhs, rhs)
		return rhs
	end;
}

function DynamicVirtualValue.implementForType(cls, expectedType, stackModes, stackModesBaseValueAssumptions)
	local DynamicVirtualTypeValue = VirtualValue.implementForType(cls, expectedType)

	local DynamicVirtualTypeValueImpl = setmetatable({}, {__index = DynamicVirtualTypeValue})
	DynamicVirtualTypeValueImpl.__index = DynamicVirtualTypeValueImpl

	-- Compose the given stackModes table with the defaultStackModes table
	DynamicVirtualTypeValueImpl.stackModes = setmetatable(stackModes or {}, {__index = DynamicVirtualValue.defaultStackModes})
	DynamicVirtualTypeValueImpl.stackModesBaseValueAssumptions = stackModesBaseValueAssumptions or {}

	function DynamicVirtualTypeValueImpl.new(stackMode, initValue)
		initValue = initValue or DynamicVirtualTypeValueImpl.stackModesBaseValueAssumptions[stackMode]
		local self = setmetatable(DynamicVirtualTypeValue.new(initValue), DynamicVirtualTypeValueImpl)
		self.stackFunc = assert(
			DynamicVirtualTypeValueImpl.stackModes[stackMode],
			("unknown stack mode: %s"):format(tostring(stackMode))
		)
		return self
	end

	function DynamicVirtualTypeValueImpl:stack(lhs, rhs)
		return self.stackFunc(lhs, rhs)
	end

	return DynamicVirtualTypeValueImpl
end

--- Constructs a new DynamicVirtualValue which contains a certain `expectedType`
-- @constructor
-- @tparam string expectedType expected type (or table of expected types) to be contained
function DynamicVirtualValue.new(expectedType)
	local self = setmetatable(VirtualValue.new(expectedType), DynamicVirtualValue)
	self._dirty = false
	self._cachedValue = nil
	
	self._children = {}
	self._childIndeces = {}
	self._maid:addTask(function ()
		self:removeAllChildren()
		self._children = nil
		self._childIndeces = nil
	end)
	
	self._childChangeConns = {}
	self._maid:addTask(function ()
		for child, conns in pairs(self._childChangeConns) do
			for conn in pairs(conns) do
				conn:disconnect()
				conns[conn] = nil
			end
			self._childChangeConns[child] = nil
		end
		self._childChangeConns = nil
	end)

	--- Fires when a @{VirtualValue} is @{DynamicVirtualValue:addChild|added} as a child
	-- @event onChildAdded
	-- @tparam VirtualValue child The child that was added
	self.onChildAdded = Event.new()
	self._maid:addTask(self.onChildAdded)
	
	--- Fires when a child is @{DynamicVirtualValue:removeChild|removed}
	-- @event onChildRemoved
	-- @tparam VirtualValue child The child that was removed
	self.onChildRemoved = Event.new()
	self._maid:addTask(self.onChildRemoved)
	
	--- Fires when the @{DynamicVirtualValue:getBase|base value} is changed or any child is changed/dirtied, indicating the value must be
	-- recaluclated the next time it is @{DynamicVirtualValue:get|gotten}.
	-- @event onDirtied
	self.onDirtied = Event.new()
	self._maid:addTask(self.onDirtied)
	
	return self
end

--- Returns the current value passed to `tostring`, followed by a comma-separated
-- list of the child values passed to `tostring`.
-- @treturn string
function DynamicVirtualValue:__tostring()
	local s = VirtualValue.__tostring(self)
	if #self._children > 0 then
		s = s .. " ("
		for i, child in ipairs(self._children) do
			if i > 2 then s = s .. ", " end
			s = s .. tostring(child)
		end
		s = s .. ")"
	end
	return s
end

--- (Abstract) Defines how two values are "stacked" together, usually through some operation.
--@param _lhs The left-hand side of the operation
--@param _rhs The right-hand side of the operation
function DynamicVirtualValue:stack(_lhs, _rhs)
	error("DynamicVirtualValue:stack is abstract must be overridden")
end

--- Sets the dirty bit on this value then fires @{DynamicVirtualValue:onDirtied|onDirtied}, if the value wasn't already dirty.
-- @private
function DynamicVirtualValue:_setDirty()
	if not self._dirty then
		self._dirty = true
		self.onDirtied:fire()
	end
end

--- Returns whether this value is dirty and will be recalculated the next time it is @{DynamicVirtualValue:get|gotten}
-- @treturn boolean Whether this value is dirty
function DynamicVirtualValue:isDirty()
	return self._dirty
end

--- Returns an array (numerically-indexed table) of the children.
function DynamicVirtualValue:getChildren()
	local children = {}
	for i, child in ipairs(self._children) do
		children[i] = child
	end
	return children
end

--- Returns an iterator function which returns each index-child pair
-- @usage for i, child in dvv:children() do ... end
function DynamicVirtualValue:children()
	return ipairs(self._children)
end

--- Returns whether the given object is a child
-- @param child The object to query
-- @treturn boolean
function DynamicVirtualValue:isChild(child)
	return type(self._childIndeces[child]) ~= "nil"
end

--- Adds the given @{VirtualValue} as a child. Dirties the DVV and fires @{DynamicVirtualValue:onChildAdded|onChildAdded}.
-- When this child is @{VirtualValue.onChange|changed} or dirtied (for child DVVs), this DVV is dirtied.
-- @tparam VirtualValue child The child to add
-- @treturn number The child's index
function DynamicVirtualValue:addChild(child)
	assert(not self:isChild(child), "child already added")
	local idx = #self._children + 1
	self._children[idx] = child
	self._childIndeces[child] = idx
	local conns = {}
	conns[child.onChanged:connect(function (newValue)
		return self:_onChildChanged(child, newValue)
	end)] = true
	-- Indicates that this child is a DynamicVirtualValue
	if child.onDirtied then
		-- Listen for when the child DynamicVirtualValue is dirtied,
		-- so we can mark this one as dirty as well (dirty status bubbles up)
		conns[child.onDirtied:connect(function ()
			self:_setDirty()
		end)] = true
	end
	self._childChangeConns[child] = conns
	self:_setDirty()
	self.onChildAdded:fire(child)
	return idx
end

function DynamicVirtualValue:_getVirtualValueClass()
	return assert(self.VirtualValueClass, "VirtualValueClass is not set")
end

--- Constructs a new child with the given parameters using the implementation's associated @{VirtualValue}
-- implementation, then @{DynamicVirtualValue:addChild|adds} it.
-- For example, @{DynamicVirtualNumberValue}:newChild constructs a @{VirtualNumberValue}). The child will
-- be @{VirtualValue:cleanup|cleaned up} when this value is cleaned up.
-- @param ... The arguments to pass to the VirtualValue constructor
-- @return The newly-constructed child
-- @usage local dvnv = DynamicVirtualNumberValue.new("Add", 3)
--dvnv:newChild(5)
function DynamicVirtualValue:newChild(...)
	local child = self:_getVirtualValueClass().new(...)
	self:addChild(child)
	self._maid:addTask(child)
	return child
end

--- Constructs multiple @{DynamicVirtualValue:newChild|new children} with the table of single parameters.
-- @return A table of all the newly-constructed children
function DynamicVirtualValue:newChildren(values)
	local children = {}
	for _i, value in ipairs(values) do
		table.insert(children, self:newChild(value))
	end
	return children
end

--- Called when a child value @{VirtualValue:onChange|changes}. @{DynamicVirtualValue:_setDirty|Dirties} this value.
-- @tparam VirtualValue _child The child
-- @param _newValue The child's new value
-- @private
function DynamicVirtualValue:_onChildChanged(_child, _newValue)
	self:_setDirty()
end

--- @{DynamicVirtualValue:addChild|Adds} a table of children
-- @tparam table children The children to add
function DynamicVirtualValue:addChildren(children)
	for _i, child in ipairs(children) do
		self:addChild(child)
	end
end

--- Returns the index of the given child
-- @treturn number The index of the child
function DynamicVirtualValue:getChildIndex(child)
	for i = #self._children, 1, -1 do
		if self._children[i] == child then
			return i
		end
	end
end

--- Removes the child at the given index. Dirties the DVV and fires @{DynamicVirtualValue:onChildRemoved|onChildRemoved}
-- @tparam number idx The index of the child to remove
function DynamicVirtualValue:removeChildAtIndex(idx)
	local child = self._children[idx]
	self._childIndeces[child] = nil
	for conn in pairs(self._childChangeConns[child]) do
		conn:disconnect()
		self._childChangeConns[child][conn] = nil
	end
	self._childChangeConns[child] = nil
	-- Do the removal
	table.remove(self._children, idx)
	-- table.remove shifts children to fill gaps; this makes indeces out of date in _childIndeces
	-- so, we need to adjust ensure the indeces in _childIndeces reflect this
	for i = idx, #self._children do
		local child2 = self._children[i]
		self._childIndeces[child2] = self._childIndeces[child2] - 1
	end
	self:_setDirty()
	self.onChildRemoved:fire(child)
end

--- Removes the child similar to how @{DynamicVirtualValue:removeChildAtIndex|removeChildAtIndex} does
function DynamicVirtualValue:removeChild(child)
	assert(self:isChild(child), "child not added")
	self:removeChildAtIndex(self._childIndeces[child])
end

--- @{DynamicVirtualValue:removeChild|Removes} all children
function DynamicVirtualValue:removeAllChildren()
	-- Removal searches for value from end of list
	-- So, removing all children in LIFO order gives O(n) runtime
	for _i = #self._children, 1, -1 do
		self:removeChild(self._children[1])
	end
end

--- Recalculates the stacked value using the @{DynamicVirtualValue:getBase|base value} and all the child values.
-- The clean (not @{DynamicVirtualValue:getDirty|dirty}) result is cached.
-- @private
function DynamicVirtualValue:_recalculate()
	local value = self:getBase()
	for i = 1, #self._children do
		value = self:stack(value, self._children[i]:get())
	end
	self._cachedValue = value
	self._dirty = false
end

--- Returns the base value, which is the raw value stored by this DynamicVirtualValue.
-- @see VirtualValue:get
-- @see DynamicVirtualValue:get
function DynamicVirtualValue:getBase()
	return VirtualValue.get(self)
end

--- Sets the new base value
-- @param newValue The new base value
function DynamicVirtualValue:set(newValue)
	local didChange = self._value ~= newValue
	VirtualValue.set(self, newValue)
	if didChange then
		self:_setDirty()
	end
end

--- Gets the stacked value, recalculating it if @{DynamicVirtualValue:isDirty|dirty}
-- @return The calculated stack value
function DynamicVirtualValue:get()
	if self._dirty then
		self:_recalculate()
	end
	return self._cachedValue
end

--- Calls `func` immediately with the stacked value, then again every time this value is
-- @{DynamicVirtualValue:isDirty|dirtied}.
-- As this function must @{DynamicVirtualValue:get|get} the current value each time it is dirtied, it will cause
-- continual recalculations. This can negatively affect runtimes if you are making lots of changes while the
-- connection is active. Therefore, it's recommended you disconnect if you're excessively dirtying the value so you
-- don't cause needless recalculations.
-- @tparam function func The listener function
-- @treturn Connection When disconnected, stops `func` from being called when the value changes
-- @see VirtualValue:bind
function DynamicVirtualValue:listen(func)
	local function speak()
		func(self:get())
	end
	coroutine.wrap(speak)()
	return self.onDirtied:connect(speak)
end

--- Sets `object[property]` to the stacked value, then again every time this value is 
-- @{DynamicVirtualValue:isDirty|dirtied}.
-- As this function must @{DynamicVirtualValue:get|get} the current value each time it is dirtied, it will cause
-- continual recalculations. This can negatively affect runtimes if you are making lots of changes while the
-- connection is active. Therefore, it's recommended you disconnect if you're excessively dirtying the value so you
-- don't cause needless recalculations.
-- @param object A table, userdata, etc which can accept `[property] = ...`
-- @tparam string property The index on `object` to set
-- @treturn Connection When disconnected, stops `func` from being called when the DVV is dirtied
-- @see VirtualValue:listen
function DynamicVirtualValue:bind(object, property)
	local function update()
		object[property] = self:get()
	end
	coroutine.wrap(update)()
	return self.onDirtied:connect(update)
end

return DynamicVirtualValue
