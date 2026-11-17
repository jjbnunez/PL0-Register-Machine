local RegisterInterface = require("domain.entities.register.register_interface")

local RegisterImplementation = { data_ = 0 }

function RegisterImplementation:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    RegisterInterface:implement(o)
    return o
end

function RegisterImplementation:get()
    return self.data_
end

function RegisterImplementation:set(data)
    self.data_ = data
end

return RegisterImplementation
