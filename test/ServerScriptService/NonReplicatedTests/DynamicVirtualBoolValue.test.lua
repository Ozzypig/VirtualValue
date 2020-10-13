local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local VirtualBoolValue = require("VirtualValue:Types.Bool")
local DynamicVirtualBoolValue = require("VirtualValue:Types.Bool.Dynamic")

local DynamicVirtualBoolValueTest = {}

DynamicVirtualBoolValueTest["test_DynamicVirtualBoolValue"] = function ()
	local dvbv = DynamicVirtualBoolValue.new("And")
	assert(dvbv, "DynamicVirtualBoolValue.new should instatiate")
	assert(dvbv:getBase() == true, "DynamicVirtualBoolValue.new with stackMode \"And\" should assume true as base value if not provided one")
	assert(dvbv:get() == true, "DynamicVirtualBoolValue.new with stackMode \"And\" default value should be true")
	dvbv:cleanup()
	dvbv = nil
	
	dvbv = DynamicVirtualBoolValue.new("Or")
	assert(dvbv, "DynamicVirtualBoolValue.new should instatiate")
	assert(dvbv:getBase() == false, "DynamicVirtualBoolValue.new with stackMode \"Or\" should assume false as base value if not provided one")
	assert(dvbv:get() == false, "DynamicVirtualBoolValue.new with stackMode \"Or\" default value should be false")
	dvbv:cleanup()
	dvbv = nil
	
	dvbv = DynamicVirtualBoolValue.new("And")
	local vbv = VirtualBoolValue.new(false)
	dvbv:addChild(vbv)
	assert(dvbv:get() == false, "DynamicVirtualBoolValue.new with stackMode \"And\" should apply and operator to base and children")
	dvbv:removeChild(vbv)
	vbv:cleanup()
	vbv = nil
	dvbv:cleanup()
	dvbv = nil
	
	dvbv = DynamicVirtualBoolValue.new("Or")
	vbv = VirtualBoolValue.new(true)
	dvbv:addChild(vbv)
	assert(dvbv:get() == true, "DynamicVirtualBoolValue.new with stackMode \"Or\" should apply or operator to base and children")
	dvbv:removeChild(vbv)
	vbv:cleanup()
	vbv = nil
	dvbv:cleanup()
	dvbv = nil
	
	-- Many values
	dvbv = DynamicVirtualBoolValue.new("And")
	local vbvs = {}
	for i = 1, 10 do
		vbvs[i] = VirtualBoolValue.new(true)
		dvbv:addChild(vbvs[i])
	end
end

DynamicVirtualBoolValueTest["test_DynamicVirtualBoolValue_nesting"] = function ()
	local dvbvRoot = DynamicVirtualBoolValue.new("And")
	local dvbvChild = DynamicVirtualBoolValue.new("And")
	local vbv = VirtualBoolValue.new(false)
	dvbvRoot:addChild(dvbvChild)
	assert(dvbvRoot:get() == true, "Value of root DynamicVirtualBoolValue should be true")
	assert(dvbvChild:get() == true, "Value of child DynamicVirtualBoolValue should be true")
	dvbvChild:addChild(vbv)
	assert(dvbvChild:get() == false, "After adding descendant false VirtualBoolValue, the Value of child DynamicVirtualBoolValue should be false")
	assert(dvbvRoot:get() == false, "After adding descendant false VirtualBoolValue, the Value of root DynamicVirtualBoolValue should be false")
end

DynamicVirtualBoolValueTest["test_DynamicVirtualBoolValue_newChild"] = function ()
	local dvnv = DynamicVirtualBoolValue.new("Or", false)
	dvnv:newChild(true)
	assert(dvnv:get() == true, "DynamicVirtualBoolValue:newChild should add a new VirtualSBoolValue child")
end

return DynamicVirtualBoolValueTest
