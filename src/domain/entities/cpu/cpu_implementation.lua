local CpuInterface = require("domain.entities.cpu.cpu_interface")

local CpuImplementation = {}

function CpuImplementation:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    CpuInterface:implement(o)
    return o
end

function CpuImplementation:fetch(op)
    print("I fetched with op " .. op)
end

function CpuImplementation:execute(op)
    print("I executed with op " .. op)
end

return CpuImplementation
