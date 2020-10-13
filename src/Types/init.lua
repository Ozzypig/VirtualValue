-- Directory for VirtualValue types

local Types = {}

Types["number"] = require(script.Number)
Types["string"] = require(script.String)
Types["boolean"] = require(script.Bool)
Types["bool"] = Types["boolean"]

return Types
