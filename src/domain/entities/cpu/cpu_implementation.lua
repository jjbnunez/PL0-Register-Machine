local CpuInterface = require("domain.entities.cpu.cpu_interface")
local InstructionImplementation = require("domain.entities.instruction.instruction_implementation")

local CpuImplementation = {
    sp = 0,
    bp = 1,
    pc = 0,
    ir_ = 0
}

function CpuImplementation:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    CpuInterface:implement(o)
    return o
end

function CpuImplementation:getIr()
    return self.ir_
end

function CpuImplementation:fetch()
    self.ir_ = self.pc
    self.pc = self.pc + 1
end

function CpuImplementation:execute(op)
    print("I executed with op " .. op)
end

return CpuImplementation
