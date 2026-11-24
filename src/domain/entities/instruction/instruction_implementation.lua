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

function M:getOpString()
    if self.op_ == 1 then
        return "lit"
    elseif self.op_ == 2 then
        return "rtn"
    elseif self.op_ == 3 then
        return "lod"
    elseif self.op_ == 4 then
        return "sto"
    elseif self.op_ == 5 then
        return "cal"
    elseif self.op_ == 6 then
        return "inc"
    elseif self.op_ == 7 then
        return "jmp"
    elseif self.op_ == 8 then
        return "jpc"
    elseif self.op_ == 9 then
        return "sio"
    elseif self.op_ == 10 then
        return "neg"
    elseif self.op_ == 11 then
        return "add"
    elseif self.op_ == 12 then
        return "sub"
    elseif self.op_ == 13 then
        return "mul"
    elseif self.op_ == 14 then
        return "div"
    elseif self.op_ == 15 then
        return "odd"
    elseif self.op_ == 16 then
        return "mod"
    elseif self.op_ == 17 then
        return "eql"
    elseif self.op_ == 18 then
        return "neq"
    elseif self.op_ == 19 then
        return "lss"
    elseif self.op_ == 20 then
        return "leq"
    elseif self.op_ == 21 then
        return "gtr"
    elseif self.op_ == 22 then
        return "geq"
    else
        io.stderr:write("Invalid opcode: ", self.op_)
    end
end

return M
