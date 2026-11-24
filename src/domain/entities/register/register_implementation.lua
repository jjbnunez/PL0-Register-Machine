--[[ register_implementation.lua ]]

local RegisterInterface = require("domain.entities.register.register_interface")

local M = { data_ = 0 }

function M:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    RegisterInterface:implement(o)
    return o
end

function M:get()
    return self.data_
end

function M:set(data)
    self.data_ = data
end

return M
