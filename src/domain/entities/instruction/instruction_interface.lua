local InstructionInterface = {
    required_methods = {
        "getOp",
        "setOp",
        "getR",
        "setR",
        "getL",
        "setL",
        "getM",
        "setM"
    }
}

function InstructionInterface:implement(class)
    for _, method in ipairs(self.required_methods) do
        if type(class[method]) ~= "function" then
            error(string.format("Class must implement method: %s", method))
        end
    end
end

return InstructionInterface
