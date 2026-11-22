--[[ cpu_implementation.lua ]]

local CpuInterface = require("domain.entities.cpu.cpu_interface")

local M = {
    sp_ = 0,
    bp_ = 1,
    pc_ = 0,
    ir_ = 0
}

function M:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    CpuInterface:implement(o)
    return o
end

function M:getSp()
    return self.sp_
end

function M:setSp(sp)
    self.sp_ = sp
end

function M:getBp()
    return self.bp_
end

function M:setBp(bp)
    self.bp_ = bp
end

function M:getPc()
    return self.pc_
end

function M:setPc(pc)
    self.pc_ = pc
end

function M:getIr()
    return self.ir_
end

function M:setIr(ir)
    self.ir_ = ir
end

function M:fetch()
    self.ir_ = self.pc_
    self.pc_ = self.pc_ + 1
end

function M:execute(op)
    print("I executed with op " .. op)
end

return M
