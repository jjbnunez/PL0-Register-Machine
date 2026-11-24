-- Note: main.lua must be executed from the
-- directory it's in in order for these import
-- statements to work properly.
local CpuImplementation = require("domain.entities.cpu.cpu_implementation")
local RegisterImplementation = require("domain.entities.register.register_implementation")
local InstructionImplementation = require("domain.entities.instruction.instruction_implementation")

MAX_LEXI_LEVELS = 3
MAX_STACK_HEIGHT = 2000
MAX_REGISTERS = 8
MAX_CODE_LENGTH = 500

stack_counter = 0

-- 16 modulus
local function MOD(from, from2)
    local to = -1
    if from2 == 0 then
        print("You are currently trying to divide by zero. Stop that.")
        return 0xdeadbeef
    else
        to = from % from2
        return to
    end
end

-- 17 equal
local function EQL(from, from2)
    if from == from2 then
        return 1
    else
        return 0
    end
end

local function NEQ(from, from2)
    if from == from2 then
        return 0
    else
        return 1
    end
end

-- 19 less than
local function LSS(from, from2)
    if from < from2 then
        return 1
    else
        return 0
    end
end

-- 20 less than or equal to
local function LEQ(from, from2)
    if from <= from2 then
        return 1
    else
        return 0
    end
end

-- 21 greater than
local function GTR(from, from2)
    if from > from2 then
        return 1
    else
        return 0
    end
end

local function GEQ(from, from2)
    if from >= from2 then
        return 1
    else
        return 0
    end
end

local function base(l, base_pointer, stack)
    local bl = base_pointer
    while l > 0 do
        local index = bl + l
        bl = stack[index]
        l = l - 1
    end
    return bl
end

local function read_input_file(filename)
    local ifp = assert(io.open(filename, "r"))
    local ofp = assert(io.open("op_printout.txt", "w"))
    local ofp2 = assert(io.open("stack_trace.txt", "w"))

    local lines = {}
    for line in ifp:lines() do
        table.insert(lines, line)
    end

    ifp:close()
    ofp:close()
    ofp2:close()

    return lines
end

local function init_op_printout(filename)
    local ofp = assert(io.open(filename, "w"))
    ofp:close()
end

local function write_op_printout(filename, instructions)
    local ofp = assert(io.open(filename, "a"))
    for i=0, #instructions do
        ofp:write(string.format("%d ", i))
        ofp:write(string.format("%s ", instructions[i]:getOpString()))
        ofp:write(string.format("%d ", instructions[i]:getR()))
        ofp:write(string.format("%d ", instructions[i]:getL()))
        ofp:write(string.format("%d\n", instructions[i]:getM()))
    end
    ofp:close()
end

local function init_stack_trace(filename)
    local ofp = assert(io.open(filename, "w"))
    ofp:write("Initial Values\t\t\t\tpc\t\tbp\t\tsp\n")
    ofp:close()
end

local function write_stack_trace(filename, opcode, r, l, m, stack, cpu, registers)
    local ofp = assert(io.open(filename, "a"))
    ofp:write(string.format("%d\t", cpu:getIr()))
    ofp:write(string.format("%s\t", opcode))
    ofp:write(string.format("%5d\t", r))
    ofp:write(string.format("%5d\t", l))
    ofp:write(string.format("%5d\t", m))
    ofp:write(string.format("%5d\t", cpu:getPc()))
    ofp:write(string.format("%5d\t", cpu:getBp()))
    ofp:write(string.format("%5d\t", cpu:getSp()))
    local stack_counter_increment = 0
    while stack_counter_increment < stack_counter + 5 do
        if stack_counter_increment > 0 then
            ofp:write(" ")
        end
        ofp:write(stack[stack_counter_increment + 1])
        stack_counter_increment = stack_counter_increment + 1
    end
    ofp:write("\n")
    ofp:close()
end

local function debugprint(instructions, cpu, stack, registers)
    local ir = cpu:getIr()
    io.stdout:write("BEGIN DEBUG PRINT\n")
    io.stderr:write(string.format("Last instruction:\n\tpc %d\n\top %d\n\tr %d\n\tl %d\n\tm %d\n", ir,
        instructions[ir]:getOp(), instructions[ir]:getR(), instructions[ir]:getL(), instructions[ir]:getM()))
    io.stderr:write("\nRegisters:\n")
    for j = 0, MAX_REGISTERS - 1 do
        io.stderr:write(string.format("\tR[%02d]: %d\n", j, registers[j]:get()))
    end
    io.stderr:write("\n")
    io.stderr:write("Stack: ")
    for j = 0, cpu:getSp() do
        io.stderr:write(stack[j])
    end
    io.stderr:write("\n")
    io.stdout:write("END DEBUG PRINT\n")
end

local function execute(instructions, cpu, stack, registers)
    local ir = cpu:getIr()
    local opcode = instructions[ir]:getOpString()
    local op = instructions[ir]:getOp()
    local r = instructions[ir]:getR()
    local l = instructions[ir]:getL()
    local m = instructions[ir]:getM()
    local halt = 0

    if op == 1 then
        registers[r]:set(m)
    elseif op == 2 then
        cpu:setSp(cpu:getBp() - 1)
        cpu:setBp(stack[cpu:getSp() + 3])
        cpu:setPc(stack[cpu:getSp() + 4])
    elseif op == 3 then
        registers[r]:set(stack[base(l, cpu:getBp(), stack) + m])
    elseif op == 4 then
        stack[base(l, cpu:getBp(), stack) + m] = registers[r]:get()
        stack_counter = stack_counter + 1
    elseif op == 5 then
        stack[cpu:getSp() + 1] = 0 -- space to return value
        stack_counter = stack_counter + 1
        stack[cpu:getSp() + 2] = base(l, cpu:getBp(), stack) -- static link
        stack_counter = stack_counter + 1
        stack[cpu:getSp() + 3] = cpu:getBp() -- dynamic link
        stack_counter = stack_counter + 1
        stack[cpu:getSp() + 4] = cpu:getPc() -- return address
        stack_counter = stack_counter + 1
        cpu:setBp(cpu:getSp() + 1)
        cpu:setPc(m)
    elseif op == 6 then
        cpu:setSp(cpu:getSp() + m)
    elseif op == 7 then
        cpu:setPc(m)
        pc = m
    elseif op == 8 then
        if registers[r]:get() == 0 then
            cpu:setPc(m)
        end
    elseif op == 9 then
        if m == 1 then
            io.stdout:write("output is: ", registers[r]:get(), "\n")
        elseif m == 2 then
            --scanf("%d", &R[reg])
        elseif m == 3 then
            halt = 1
        end
    elseif op == 10 then
        registers[r]:set(-registers[l]:get())
    elseif op == 11 then
        registers[r]:set(registers[l]:get() + registers[m]:get())
    elseif op == 12 then
        registers[r]:set(registers[l]:get() - registers[m]:get())
    elseif op == 13 then
        registers[r]:set(registers[l]:get() * registers[m]:get())
    elseif op == 14 then
        registers[r]:set(math.floor(registers[l]:get() / registers[m]:get()))
    elseif op == 15 then
        registers[r]:set(registers[r]:get() % 2)
    elseif op == 16 then
        registers[r]:set(MOD(registers[l]:get(), registers[m]:get()))
    elseif op == 17 then
        registers[r]:set(EQL(registers[l]:get(), registers[m]:get()))
    elseif op == 18 then
        registers[r]:set(NEQ(registers[l]:get(), registers[m]:get()))
    elseif op == 19 then
        registers[r]:set(LSS(registers[l]:get(), registers[m]:get()))
    elseif op == 20 then
        registers[r]:set(LEQ(registers[l]:get(), registers[m]:get()))
    elseif op == 21 then
        registers[r]:set(GTR(registers[l]:get(), registers[m]:get()))
    elseif op == 22 then
        registers[r]:set(GEQ(registers[l]:get(), registers[m]:get()))
    else
        io.stderr:write("Invalid opcode: ", op)
    end

    write_stack_trace("stack_trace.txt", opcode, r, l, m, stack, cpu, registers)

    return halt
end

local function get_instructions(lines)
    local instructions = {}

    for i = 0, #lines - 1 do
        local numbers = {}
        for number in string.gmatch(lines[i + 1], "%d+") do
            numbers[#numbers + 1] = number
        end
        local instruction = InstructionImplementation:new()
        local op = tonumber(numbers[1])
        local r = tonumber(numbers[2])
        local l = tonumber(numbers[3])
        local m = tonumber(numbers[4])
        instruction:setOp(op)
        instruction:setR(r)
        instruction:setL(l)
        instruction:setM(m)
        instructions[i] = instruction
    end
    return instructions
end

local function main()
    local stack = {}
    for i = 0, MAX_STACK_HEIGHT - 1 do
        stack[i] = 0
    end

    local registers = {}
    for i = 0, MAX_REGISTERS - 1 do
        registers[i] = RegisterImplementation:new()
    end

    local instructions = get_instructions(read_input_file("input_file.txt"))
    init_op_printout("op_printout.txt")
    write_op_printout("op_printout.txt", instructions);

    init_stack_trace("stack_trace.txt")

    local cpu = CpuImplementation:new()

    local halt = 0
    while halt ~= 1 and cpu:getPc() < MAX_CODE_LENGTH - 1 do
        cpu:fetch()
        halt = execute(instructions, cpu, stack, registers)
        if halt == 1 then
            debugprint(instructions, cpu, stack, registers)
            break
        end
    end
end

main()
