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

local function file_scan(filename)
    local ifp = assert(io.open(filename, "r"))
    local ofp = assert(io.open("opprintout.txt", "w"))
    local ofp2 = assert(io.open("stacktrace.txt", "w"))

    local lines = {}
    for line in ifp:lines() do
        table.insert(lines, line)
    end

    ifp:close()
    ofp:close()
    ofp2:close()

    return lines
end

local function opprint(filename, line, opcode, r, l, m)
    local ofp = assert(io.open(filename, "a"))
    ofp:write(line, opcode, r, l, m)
    ofp:close()
end

local function stack_trace(filename, opcode, r, l, m, stack, processor, regs)
    local ofp = assert(io.open(filename, "a"))
    ofp:write(string.format("%d", processor:getIr()))
    ofp:write(string.format("%s\t", opcode))
    ofp:write(string.format("%5d\t", r))
    ofp:write(string.format("%5d\t", l))
    ofp:write(string.format("%5d\t", m))
    ofp:write(string.format("%5d\t", processor.pc))
    ofp:write(string.format("%5d\t", processor.bp))
    ofp:write(string.format("%5d\t", processor.sp))
    ofp:write(string.format("\n\n"))
    local stack_counter_increment = 0
    while stack_counter_increment < stack_counter + 5 do
        print(string.format("stack_counter_increment = %d", stack_counter_increment+1))
        ofp:write(stack[stack_counter_increment + 1])
        stack_counter_increment = stack_counter_increment + 1
    end
    ofp:write("\n")
    ofp:write("Registers:\n")
    for j = 0, MAX_REGISTERS - 1 do
        ofp:write(regs[j]:get())
    end
    ofp:write("\n")
    ofp:close()
end

local function debugprint(instructions, processor, pc, stack, registers)
    io.stdout:write("BEGIN DEBUG PRINT\n")
    io.stderr:write(string.format("Last instruction:\n\tpc %d\n\top %d\n\tr %d\n\tl %d\n\tm %d\n", pc,
        instructions[pc]:getOp(), instructions[pc]:getR(), instructions[pc]:getL(), instructions[pc]:getM()))
    io.stderr:write("\nRegisters:\n")
    for j = 0, MAX_REGISTERS-1 do
        io.stderr:write(string.format("\tR[%02d]: %d\n", j, registers[j]:get()))
    end
    io.stderr:write("\n")
    io.stderr:write("Stack: ")
    for j = 0, processor.bp + 1 do
        io.stderr:write(stack[j])
    end
    io.stderr:write("\n")
    io.stdout:write("END DEBUG PRINT\n")
end

local function init()
    local processor = CpuImplementation:new()
    local ofp = assert(io.open("stacktraceoutput.txt", "w"))
    ofp:write("Initial Values\t\t\t\tpc\t\tbp\t\tsp\n")
    ofp:close()
    return processor
end

local function execute(instructions, processor, stack, R)
    local ir = processor:getIr()
    local op = instructions[ir]:getOp()
    local reg = instructions[ir]:getR()
    local level = instructions[ir]:getL()
    local m = instructions[ir]:getM()

    local opcode
    if op == 1 then
        opcode = "lit"
        R[reg]:set(m)
    elseif op == 2 then
        opcode = "rtn"
        processor.sp = processor.bp - 1
        processor.bp = stack[processor.ir + 3]
        processor.pc = stack[processor.ir + 4]
    elseif op == 3 then
        opcode = "lod"
        R[reg]:set(stack[base(level, processor.bp, stack) + m])
    elseif op == 4 then
        opcode = "sto"
        stack[base(level, processor.bp, stack) + m] = R[reg]:get()
        stack_counter = stack_counter + 1
    elseif op == 5 then
        opcode = "cal"
        stack[processor.sp + 1] = 0
        stack_counter = stack_counter + 1
        stack[processor.sp + 2] = base(level, processor.bp, stack)
        stack_counter = stack_counter + 1
        stack[processor.sp + 3] = processor.bp
        stack_counter = stack_counter + 1
        stack[processor.sp + 4] = ir
        stack_counter = stack_counter + 1
        processor.bp = processor.sp + 1
        processor.pc = m - 1
    elseif op == 6 then
        opcode = "inc"
        processor.sp = processor.sp + m
    elseif op == 7 then
        opcode = "jmp"
        processor.pc = m - 1
        pc = m
    elseif op == 8 then
        opcode = "jpc"
        if R[reg]:get() == 0 then
            processor.pc = m - 1
        end
    elseif op == 9 then
        opcode = "sio"
        if m == 1 then
            io.stdout:write("output is: ", R[reg]:get(), "\n")
        elseif m == 2 then
            --scanf("%d", &R[reg])
        elseif m == 3 then
            return 1
        end
    elseif op == 10 then
        opcode = "neg"
        R[reg]:set(-R[level]:get())
    elseif op == 11 then
        opcode = "add"
        R[reg]:set(R[level]:get() + R[m]:get())
    elseif op == 12 then
        opcode = "sub"
        R[reg]:set(R[level]:get() - R[m]:get())
    elseif op == 13 then
        opcode = "mul"
        R[reg]:set(R[level]:get() * R[m]:get())
    elseif op == 14 then
        opcode = "div"
        R[reg]:set(math.floor(R[level]:get() / R[m]:get()))
    elseif op == 15 then
        opcode = "odd"
        R[reg]:set(R[reg]:get() % 2)
    elseif op == 16 then
        opcode = "mod"
        R[reg]:set(MOD(R[level]:get(), R[m]:get()))
    elseif op == 17 then
        opcode = "eql"
        R[reg]:set(EQL(R[level]:get(), R[m]:get()))
    elseif op == 18 then
        opcode = "neq"
        R[reg]:set(NEQ(R[level]:get(), R[m]:get()))
    elseif op == 19 then
        opcode = "lss"
        R[reg]:set(LSS(R[level]:get(), R[m]:get()))
    elseif op == 20 then
        opcode = "leq"
        R[reg]:set(LEQ(R[level]:get(), R[m]:get()))
    elseif op == 21 then
        opcode = "gtr"
        R[reg]:set(GTR(R[level]:get(), R[m]:get()))
    elseif op == 22 then
        opcode = "geq"
        R[reg]:set(GEQ(R[level]:get(), R[m]:get()))
    else
        io.stderr:write("Invalid opcode: ", op)
    end

    --opprint("opprintout.txt", line, opcode, reg, level, m);
    stack_trace("stacktraceoutput.txt", opcode, reg, level, m, stack, processor, R)
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
    for k = 0, #instructions do
        print(string.format("Instruction %d is %d %d %d %d", k, instructions[k]:getOp(), instructions[k]:getR(),
            instructions[k]:getL(), instructions[k]:getM()))
    end
    return instructions
end

local function main(argv)
    local cpu = CpuImplementation:new()
    local register = RegisterImplementation:new()
    local stack = {}
    local halt
    for i = 0, MAX_STACK_HEIGHT - 1 do
        stack[i] = 0
    end
    local R = {}
    for i = 0, MAX_REGISTERS - 1 do
        R[i] = RegisterImplementation:new()
    end
    print()

    local lines = file_scan(argv)
    local instructions = get_instructions(lines)
    local processor = init()
    halt = 0
    while halt ~= 1 and processor.pc < MAX_CODE_LENGTH - 1 do
        processor:fetch()
        halt = execute(instructions, processor, stack, R)
        if halt == 1 then
            debugprint(instructions, processor, processor.pc, stack, R)
            break
        end
    end
end

main("../inputfile.txt")
