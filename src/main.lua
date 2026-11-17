-- Note: main.lua must be executed from the
-- directory it's in in order for these import
-- statements to work properly.
local CpuImplementation = require("domain.entities.cpu.cpu_implementation")
local RegisterImplementation = require("domain.entities.register.register_implementation")

local cpu = CpuImplementation:new()
local register = RegisterImplementation:new()
print("Register currently contains: " .. register:get())
print("Register will be set to: " .. 5)
register:set(5)
print("Register now contains: " .. register:get())
print("Accessing register's data field directly: " .. register.data_)


MAX_LEXI_LEVELS = 3
MAX_STACK_HEIGHT = 2000
MAX_REGISTERS = 8
MAX_CODE_LENGTH = 500

Instruction = {op = 0, reg = 0, level = 0, m = 0}

CPU = {bp = 0, sp = 0, pc = 0, ir = {}, stack = {}, regfile = {}, code = {}}

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

local function file_scan(filename, buffer)
    local ifp = assert(io.open(filename, "r"))
    local ofp = assert(io.open("opprintout.txt", "w"))
    local ofp2 = assert(io.open("stacktrace.txt", "w"))
    local i
    local op
    local reg
    local level
    local m
    local opcode

    ofp:close()
    ofp2:close()

    --while ifp:read("l") do
    --end
    -- WITHIN LOOP
    if op == 1 then
        opcode = "lit"
    elseif op == 2 then
        opcode = "rtn"
    elseif op == 3 then
        opcode = "lod"
    elseif op == 4 then
        opcode = "sto"
    elseif op == 5 then
        opcode = "cal"
    elseif op == 6 then
        opcode = "inc"
    elseif op == 7 then
        opcode = "jmp"
    elseif op == 8 then
        opcode = "jpc"
    elseif op == 9 then
        opcode = "sio"
    elseif op == 10 then
        opcode = "neg"
    elseif op == 11 then
        opcode = "add"
    elseif op == 12 then
        opcode = "sub"
    elseif op == 13 then
        opcode = "mul"
    elseif op == 14 then
        opcode = "div"
    elseif op == 15 then
        opcode = "odd"
    elseif op == 16 then
        opcode = "mod"
    elseif op == 17 then
        opcode = "eql"
    elseif op == 18 then
        opcode = "neq"
    elseif op == 19 then
        opcode = "lss"
    elseif op == 20 then
        opcode = "leq"
    elseif op == 21 then
        opcode = "gtr"
    elseif op == 22 then
        opcode = "geq"
    else
        io.stderr:write("Invalid opcode: ", op)
    end

    --opprint("opprintout.txt", i, opcode, reg, level, m)
    -- END LOOP
    ifp:close()

    return buffer
end

local function opprint(filename, line, opcode, r, l, m)
    local ofp = assert(io.open(filename, "a"))
    ofp:write(line, opcode, r, l, m)
    ofp:close()
end

local function stack_trace(filename, line, opcode, r, l, m, stack, processor, regs)
    local ofp = assert(io.open(filename, "a"))
    ofp:write(line, opcode, r, l, m, processor.pc, processor.bp, processor.sp)
    local stack_counter_increment = 0
    while stack_counter_increment < stack_counter+5 do
        ofp:write(stack[stack_counter_increment])
        stack_counter_increment = stack_counter_increment + 1
    end
    ofp:write("\n")
    ofp:write("Registers: ")
    for j=0, MAX_REGISTERS do
        ofp:write(regs[j])
    end
    ofp:write("\n")
    ofp:close()
end

local function debugprint(code, proc, i, stck, regs)
    io.stderr:write(i, code[i].op, code[i].reg, code[i].level, code[i].m, "\n")
    io.stderr:write("Registers: ")
    for j=0, MAX_REGISTERS do
        io.stderr:write(regs[j])
    end
    io.stderr:write("\n")
    io.stderr:write("Stack: ")
    for j=0, proc.bp+1 do
        io.stderr:write(stck[j])
    end
    io.stderr:write("\n\n")
end

local function init(processor, stack, R)
    for i=0,MAX_STACK_HEIGHT do
        stack[i] = 0
    end
    for i=0,MAX_REGISTERS do
        R[i] = 0
    end
    processor = CPU.new()
    processor.bp = 1
    processor.sp = 0
    processor.pc = 0
    local ofp = assert(io.open("stacktraceoutput.txt", "a"))
    ofp:write("Initial Values                                          pc        bp        sp\n")
    --stack[1]=1
    return processor
end

local function execute(line, code, processor, stack, R)
    local opcode
    local op = code[line].op
    local reg = code[line].reg
    local level = code[line].level
    local m = code[line].m
    
    processor.pc = line

    if op == 1 then
        opcode = "lit"
        R[reg] = m
    elseif op == 2 then
        opcode = "rtn"
        processor.sp = processor.bp - 1
        processor.bp = stack[processor.sp + 3]
        processor.pc = stack[processor.sp + 4]
    elseif op == 3 then
        opcode = "lod"
        R[reg] = stack[base(level, processor.bp, stack) + m]
    elseif op == 4 then
        opcode = "sto"
        stack[base(level, processor.bp, stack) + m] = R[reg]
        stack_counter = stack_counter + 1
    elseif op == 5 then
        opcode = "cal"
        stack[processor.sp + 1] = 0
        stack_counter = stack_counter + 1
        stack[processor.sp + 2] = base(level, processor.bp, stack)
        stack_counter = stack_counter + 1
        stack[processor.sp + 3] = processor.bp
        stack_counter = stack_counter + 1
        stack[processor.sp + 4] = processor.pc
        stack_counter = stack_counter + 1
        processor.bp = processor.sp + 1
        processor.pc = m-1
    elseif op == 6 then
        opcode = "inc"
        processor.sp = processor.sp + m
    elseif op == 7 then
        opcode = "jmp"
        processor.pc = m - 1
        line = m
    elseif op == 8 then
        opcode = "jpc"
        if R[reg] == 0 then
            processor.pc = m - 1
            line = m
        end
    elseif op == 9 then
        opcode = "sio"
        if m == 1 then
            io.stdout:write("output is: ", R[reg], "\n")
        elseif m == 2 then
            --scanf("%d", &R[reg])
        elseif m == 3 then
            return 1
        end
    elseif op == 10 then
        opcode = "neg"
        R[reg] = -R[level]
    elseif op == 11 then
        opcode = "add"
        R[reg] = R[level] + R[m]
    elseif op == 12 then
        opcode = "sub"
        R[reg] = R[level] - R[m]
    elseif op == 13 then
        opcode = "mul"
        R[reg] = R[level] * R[m]
    elseif op == 14 then
        opcode = "div"
        R[reg] = math.floor(R[level] / R[m])
    elseif op == 15 then
        opcode = "odd"
        R[reg] = R[reg] % 2
    elseif op == 16 then
        opcode = "mod"
        R[reg] = R[level] % R[m]
    elseif op == 17 then
        opcode = "eql"
        R[reg] = EQL(R[level], R[m])
    elseif op == 18 then
        opcode = "neq"
        R[reg] = NEQ(R[level], R[m])
    elseif op == 19 then
        opcode = "lss"
        R[reg] = LSS(R[level], R[m])
    elseif op == 20 then
        opcode = "leq"
        R[reg] = LEQ(R[level], R[m])
    elseif op == 21 then
        opcode = "gtr"
        R[reg] = GTR(R[level], R[m])
    elseif op == 22 then
        opcode = "geq"
        R[reg] = GEQ(R[level], R[m])
    else
        io.stderr:write("Invalid opcode: ", op)
    end

    --opprint("opprintout.txt", line, opcode, reg, level, m);
    stack_trace("stacktraceoutput.txt", line, opcode, reg, level, m, stack, processor, R)
    -- debugprint(code, processor, line, stack, R);
end

local function main(argc, argv)
    local line
    local halt
    local stack = {}
    for i=1,MAX_STACK_HEIGHT do
        stack[i] = 0
    end
    local R = {}
    for i=1,MAX_REGISTERS do
        R[i]=0
    end
    local code
    local processor

    code = file_scan(argv[1], code)
    processor = init(processor, stack, R)
    processor.pc = 0
    halt = 0
    while halt ~= 1 and processor.pc < 500 do
        halt = execute(processor.pc, code, processor, stack, R)
        processor.pc = processor.pc + 1
    end
end

