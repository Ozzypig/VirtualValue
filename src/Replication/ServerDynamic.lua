--- 

local Server = require(script.Parent)

local DynamicServer = setmetatable({}, {__index = Server})
DynamicServer.__index = DynamicServer

function DynamicServer.new(dynamicVirtualValue, ...)
	local self = setmetatable(Server.new(dynamicVirtualValue, ...), DynamicServer)
	return self
end

return DynamicServer
