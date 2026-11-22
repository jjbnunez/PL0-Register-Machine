--[[ instruction_implementation.lua ]]

local InstructionInterface = require("domain.entities.instruction.instruction_interface")

local M = { op_ = 0, r_ = 0, l_ = 0, m_ = 0 }

function M:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    InstructionInterface:implement(o)
    return o
end

function M:getOp()
    return self.op_
end

function M:setOp(op)
    self.op_ = op
end

function M:getR()
    return self.r_
end

function M:setR(r)
    self.r_ = r
end

function M:getL()
    return self.l_
end

function M:setL(l)
    self.l_ = l
end

function M:getM()
    return self.m_
end

function M:setM(m)
    self.m_ = m
end

return M
