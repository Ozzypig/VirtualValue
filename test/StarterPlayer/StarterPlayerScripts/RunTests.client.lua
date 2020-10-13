local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestRunner = require(ReplicatedStorage:WaitForChild("TestRunner"))

local testContainer = ReplicatedStorage:WaitForChild("VirtualValueTest")

local function main()
	local testRunner = TestRunner.gather(testContainer)
	testRunner:runAndReport()
end
main()
