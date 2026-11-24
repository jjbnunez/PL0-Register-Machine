--[[ stack_implementation ]]

local StackInterface = require("domain.entities.stack.stack_interface")

local M = { data_ = {}, top_ = -1 }

function M:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    StackInterface:implement(o)
    return o
end

function M:push(o)
    self.top_ = self.top_ + 1
    self.data_[self.top_] = o
end

function M:pop()
    o = self.data_[self.top_]
    self.top_ = self.top_ - 1
    return o
end

function M:peek()
    return self.data_[self.top_]
end

function M:empty()
    return self.top_ < 0
end

return M
