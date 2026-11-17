local RegisterInterface = {
    required_methods = {
        "get",
        "set"
    }
}

function RegisterInterface:implement(class)
    for _, method in ipairs(self.required_methods) do
        if type(class[method]) ~= "function" then
            error(string.format("Class must implement method: %s", method))
        end
    end
end

return RegisterInterface
