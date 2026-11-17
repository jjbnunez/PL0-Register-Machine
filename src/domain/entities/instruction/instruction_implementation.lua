local InstructionInterface = require("domain.entities.instruction.instruction_interface")

local InstructionImplementation = { op = 0, r = 0, l = 0, m = 0}

function InstructionImplementation:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    InstructionInterface:implement(o)
    return o
end

function InstructionImplementation:getOp()
    return self.op
end

function InstructionImplementation:setOp(op)
    self.op = op
end

function InstructionImplementation:getR()
    return self.r
end

function InstructionImplementation:setR(r)
    self.r = r
end

function InstructionImplementation:getL()
    return self.l
end

function InstructionImplementation:setL(l)
    self.l = l
end

function InstructionImplementation:getM()
    return self.m
end

function InstructionImplementation:setM(m)
    self.m = m
end

return InstructionImplementation
