--[[ cpu_interface.lua ]]

local M = {
    required_methods = {
        --"new",
        "getSp",
        "setSp",
        "getBp",
        "setBp",
        "getPc",
        "setPc",
        "getIr",
        "setIr",
        "fetch",
        "execute"
    }
}

function M:implement(class)
    for _, method in ipairs(self.required_methods) do
        if type(class[method]) ~= "function" then
            error(string.format("Class must implement method: %s", method))
        end
    end
end

return M
