local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualStringValue = require("VirtualValue:Types.String")
local DynamicVirtualStringValue = require("VirtualValue:Types.String.Dynamic")

local DynamicVirtualStringValueTest = {}

DynamicVirtualStringValueTest["test_DynamicVirtualStringValue"] = function ()
    local dvsv = DynamicVirtualStringValue.new("Concat")
    assert(dvsv, "DynamicVirtualStringValue.new should instatiate")
    assert(dvsv:getBase() == "", "DynamicVirtualStringValue.new should assume empty string as base value if not provided one")
	assert(dvsv:get() == "", "DynamicVirtualStringValue.new default value should be empty string")
	dvsv:cleanup()
	dvsv = nil
	
	-- Test concat between base and children
	dvsv = DynamicVirtualStringValue.new("Concat", "Hello")
	local vsv = VirtualStringValue.new(" world")
	dvsv:addChild(vsv)
	assert(dvsv:get() == "Hello world", "Concat stack mode should concatenate base and child values")
	vsv:cleanup()
	vsv = nil
	dvsv:cleanup()
	dvsv = nil

	-- Test concat in reverse
	dvsv = DynamicVirtualStringValue.new("ConcatReverse", "world")
	vsv = VirtualStringValue.new("Hello ")
	dvsv:addChild(vsv)
	assert(dvsv:get() == "Hello world", "ConcatReverse stack mode should concatenate base and child values in reverse")
	vsv:cleanup()
	vsv = nil
	dvsv:cleanup()
	dvsv = nil

	-- Test concat between children
	dvsv = DynamicVirtualStringValue.new("Concat")
	vsv = VirtualStringValue.new("Hello")
	dvsv:addChild(vsv)
	local vsv2 = VirtualStringValue.new(" world")
	dvsv:addChild(vsv2)
	assert(dvsv:get() == "Hello world", "Concat stack mode should concatenate base and child values")
	dvsv:removeChild(vsv2)
	dvsv:removeChild(vsv)
	vsv:cleanup()
	vsv = nil
	vsv2:cleanup()
	vsv2 = nil
	dvsv:cleanup()
	dvsv = nil
end

DynamicVirtualStringValueTest["test_DynamicVirtualStringValue_Last"] = function ()
	local dvsv = DynamicVirtualStringValue.new("Last")
	
	local vals = {}
	for i = 1, 5 do
		local vsv = VirtualStringValue.new("String" .. i)
		dvsv:addChild(vsv)
		assert(dvsv:get() == vsv:get(), "stackMode \"Last\" should return the value of the last child added")
		vals[vsv] = true
	end
	for vsv in pairs(vals) do
		dvsv:removeChild(vsv)
		vsv:cleanup()
		vals[vsv] = nil
	end
	dvsv:cleanup()
	dvsv = nil
end

DynamicVirtualStringValueTest["test_DynamicVirtualStringValue_listen"] = function ()
	local dvsv = DynamicVirtualStringValue.new("Concat", "Base")

	local called = false
	local callValue
	local function listener(value)
		called = true
		callValue = value
	end

	local function reset()
		called = false
		callValue = nil
	end

	local function assertListenerCalledWithValueThenReset(expectedValue)
		assert(called, "DynamicVirtualValue:listen should've called the listener")
		assert(callValue == expectedValue,
			("DynamicVirtualValue:listen should've called the listener with value %s"):format(
				tostring(expectedValue)
			)
		)
		reset()
	end

	dvsv:listen(listener)
	assertListenerCalledWithValueThenReset("Base")

	local vsv = VirtualStringValue.new("Foobar")
	dvsv:addChild(vsv)
	assertListenerCalledWithValueThenReset("BaseFoobar")
	dvsv:removeChild(vsv)
	reset()
	local dvsv2 = DynamicVirtualStringValue.new("Concat", "Child")
	dvsv:addChild(dvsv2)
	assertListenerCalledWithValueThenReset("BaseChild")
	dvsv2:addChild(vsv)
	assertListenerCalledWithValueThenReset("BaseChildFoobar")
	dvsv2:removeChild(vsv)
	vsv:cleanup()
	vsv = nil
	dvsv:removeChild(dvsv2)
	dvsv2:cleanup()
	dvsv2 = nil
	dvsv:cleanup()
	dvsv = nil
end

DynamicVirtualStringValueTest["test_DynamicVirtualStringValue_newChild"] = function ()
	local dvnv = DynamicVirtualStringValue.new("Concat", "Hello")
	dvnv:newChild("World")
	assert(dvnv:get() == "HelloWorld", "DynamicVirtualStringValue:newChild should add a new VirtualStringValue child")
end

return DynamicVirtualStringValueTest
