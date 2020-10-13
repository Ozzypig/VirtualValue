local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualNumberValue = require("VirtualValue:Types.Number")

local VirtualNumberValueTest = {}

VirtualNumberValueTest["test_VirtualNumberValue.new"] = function ()
	local initValue = 1969290276
	local vnv = VirtualNumberValue.new(initValue)
	assert(vnv:get() == initValue, "VirtualNumberValue.new should initialize value at initValue")
end

VirtualNumberValueTest["test_VirtualNumberValue:set"] = function ()
	local newValue = 869213816
	local vnv = VirtualNumberValue.new()
	vnv:set(newValue)
	assert(vnv:get() == newValue, "VirtualNumberValue:set should set value")
end

VirtualNumberValueTest["test_VirtualNumberValue:onChange"] = function ()
	local fired = false
	local vnv = VirtualNumberValue.new()
	local newValue = 37187693
	local conn = vnv.onChange:connect(function (fireValue)
		fired = true
		assert(fireValue == newValue, "VirtualNumberValue.onChange should fire with new value")
	end)
	vnv:set(newValue)
	assert(fired, "VirtualNumberValue.onChange should fire when value is changed")

	-- Reset and fire with same value
	fired = false
	vnv:set(newValue)
	assert(not fired, "VirtualNumberValue.onChange should not fire if value does not change")

	-- Reset, disconnect
	fired = false
	conn:disconnect()
	conn = nil
	vnv:set(413861282)
	assert(not fired, "VirtualNumberValue.onChange should not fire if disconnected")
end

VirtualNumberValueTest["test_VirtualNumberValue:value"] = function ()
	local initValue = 182682386
	local vnv = VirtualNumberValue.new(initValue)
	assert(vnv:value() == initValue, "VirtualNumberValue:value() should return current value")

	local newValue = 812867123
	local retVal = vnv:value(newValue)
	assert(vnv:get() == newValue, "VirtualNumberValue:value(newValue) should set new value")
	assert(retVal == newValue, "VirtualNumberValue:value(newValue) should return new value")
end

VirtualNumberValueTest["test_VirtualNumberValue:listen"] = function ()
	local initValue = 182682386
	local vnv = VirtualNumberValue.new(initValue)

	local called
	local callValue
	local function listener(value)
		called = true
		callValue = value
	end

	-- Test immediate call
	vnv:listen(listener)
	assert(called, "VirtualNumberValue:listen should immediately call the listener")
	assert(callValue == initValue, "VirtualNumberValue:listen should immediately call the listener with the current value")

	-- Reset,  set value
	called = false
	callValue = nil
	local newValue = 9127867234
	vnv:set(newValue)
	assert(called, "VirtualNumberValue:listen should call the listener when value changes")
	assert(callValue == newValue, "VirtualNumberValue:listen should call the listener with new values")
end

return VirtualNumberValueTest
