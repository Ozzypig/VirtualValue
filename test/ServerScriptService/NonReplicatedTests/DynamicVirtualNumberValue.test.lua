local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"))

local DynamicVirtualNumberValue = require("VirtualValue:Types.Number.Dynamic")
local VirtualNumberValue = require("VirtualValue:Types.Number")

local DynamicVirtualNumberValueTest = {}

DynamicVirtualNumberValueTest["test_DynamicVirtualNumberValue"] = function ()
	local dvnv = DynamicVirtualNumberValue.new("Add")
	assert(dvnv, "DynamicVirtualNumberValue.new should instatiate")
	assert(dvnv:getBase() == 0, "DynamicVirtualNumberValue.new should assume 0 as base value if not provided one")
	assert(dvnv:get() == 0, "DynamicVirtualNumberValue.new value should be 0")
	dvnv:cleanup()
	dvnv = nil

	-- Ensure that base value assumptions are correct when they are not provided
	dvnv = DynamicVirtualNumberValue.new("Add")
	assert(dvnv:getBase() == 0, "initValue assumption for \"Add\" stackMode should be 0")
	dvnv:cleanup()
	dvnv = nil

	dvnv = DynamicVirtualNumberValue.new("Mult")
	assert(dvnv:getBase() == 1, "initValue assumption for \"Mult\" stackMode should be 1")
	dvnv:cleanup()
	dvnv = nil

	-- Ensure that a given base value (initValue) is used when provided
	local initValue = 12867823
	dvnv = DynamicVirtualNumberValue.new("Add", initValue)
	assert(dvnv:getBase() == initValue, "DynamicVirtualNumberValue.new should initialize base value")
	assert(dvnv:get() == initValue, "DynamicVirtualNumberValue.new default value should be initialized")
	dvnv:cleanup()
	dvnv = nil
end

DynamicVirtualNumberValueTest["test_DynamicVirtualNumberValue_Add"] = function ()
	local dvnv = DynamicVirtualNumberValue.new("Add", 3)
	local vnv = VirtualNumberValue.new(5)
	dvnv:addChild(vnv)
	assert(dvnv:get() == 8, "Additive stacking should add child to base")
	dvnv:cleanup()
	dvnv = nil
	vnv:cleanup()
	vnv = nil

	dvnv = DynamicVirtualNumberValue.new("Add", 0)
	vnv = VirtualNumberValue.new(3)
	dvnv:addChild(vnv)
	local vnv2 = VirtualNumberValue.new(5)
	dvnv:addChild(vnv2)
	assert(dvnv:get() == 8, "Additive stacking should stack children together additively")
	assert(not dvnv._dirty, "DynamicVirtualNumberValue should not be dirty after :get() is called")
	dvnv:removeChild(vnv2)
	assert(dvnv._dirty, "DynamicVirtualNumberValue should be dirty after child is removed")
	assert(dvnv:get() == 3, "Additive stacking should be marked dirty after child is removed")
	dvnv:removeChild(vnv)
	assert(dvnv:get() == 0, "Additive stacking should return base value once all children are removed")
	dvnv:cleanup()
	dvnv = nil
	vnv:cleanup()
	vnv = nil
	vnv2:cleanup()
	vnv2 = nil
end

DynamicVirtualNumberValueTest["test_DynamicVirtualNumberValue_Mult"] = function ()
	local dvnv = DynamicVirtualNumberValue.new("Mult", 3)
	local vnv = VirtualNumberValue.new(7)
	dvnv:addChild(vnv)
	assert(dvnv:get() == 21, "Multiplicative stacking should multiply child to base")
	dvnv:cleanup()
	dvnv = nil
	vnv:cleanup()
	vnv = nil

	dvnv = DynamicVirtualNumberValue.new("Mult", 1)
	vnv = VirtualNumberValue.new(3)
	dvnv:addChild(vnv)
	local vnv2 = VirtualNumberValue.new(7)
	dvnv:addChild(vnv2)
	assert(dvnv:get() == 21, "Multiplicative stacking should stack children together multiplicatively")
	assert(not dvnv._dirty, "DynamicVirtualNumberValue should not be dirty after :get() is called")
	dvnv:removeChild(vnv2)
	assert(dvnv._dirty, "DynamicVirtualNumberValue should be dirty after child is removed")
	assert(dvnv:get() == 3, "Multiplicative stacking should be marked dirty after child is removed")
	dvnv:removeChild(vnv)
	assert(dvnv:get() == 1, "Multiplicative stacking should return base value once all children are removed")
	dvnv:cleanup()
	dvnv = nil
	vnv:cleanup()
	vnv = nil
	vnv2:cleanup()
	vnv2 = nil
end

DynamicVirtualNumberValueTest["test_DynamicVirtualNumberValue_nesting"] = function ()
	local dvnvRoot = DynamicVirtualNumberValue.new("Mult", 2)
	local dvnvChild = DynamicVirtualNumberValue.new("Mult", 3)
	local vbv = VirtualNumberValue.new(5)
	dvnvRoot:addChild(dvnvChild)
	assert(dvnvRoot:get() == 6, "Value of root DynamicVirtualNumberValue should be 2*3=6")
	assert(dvnvChild:get() == 3, "Value of child DynamicVirtualNumberValue should be 3")
	
	dvnvChild:addChild(vbv)
	assert(dvnvRoot:get() == 30, "After adding first descendant VirualNumberValue (5), the Value of root DynamicVirtualNumberValue should be 2*3*5=30")
	assert(dvnvChild:get() == 15, "After adding first descendant VirualNumberValue (5), the Value of child DynamicVirtualNumberValue should be 3*5=15")
	
	local vbv2 = VirtualNumberValue.new(7)
	dvnvChild:addChild(vbv2)
	assert(dvnvRoot:get() == 210, "After adding second descendant VirualNumberValue (7), the Value of root DynamicVirtualNumberValue should be 2*3*5*7=210")
	assert(dvnvChild:get() == 105, "After adding second descendant VirualNumberValue (7), the Value of child DynamicVirtualNumberValue should be 3*5*7=105")

	dvnvChild:removeChild(vbv2)
	vbv2:cleanup()
	vbv2 = nil
	assert(dvnvRoot:get() == 30, "After adding first descendant VirualNumberValue (5), the Value of root DynamicVirtualNumberValue should be 2*3*5=30")
	assert(dvnvChild:get() == 15, "After adding first descendant VirualNumberValue (5), the Value of child DynamicVirtualNumberValue should be 3*5=15")
end

DynamicVirtualNumberValueTest["test_DynamicVirtualNumberValue_newChild"] = function ()
	local dvnv = DynamicVirtualNumberValue.new("Add", 2)
	dvnv:newChild(3)
	assert(dvnv:get() == 5, "DynamicVirtualNumberValue:newChild should add a new VirtualNumberValue child")
end

return DynamicVirtualNumberValueTest
