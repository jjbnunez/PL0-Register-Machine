class Cpu (bp: Int, sp: Int, pc: Int, ir: Int) {
    var basePointer = Register(bp)
    var stackPointer = Register(sp)
    var programCounter = Register(pc)
    var instructionRegister = Register(ir)
}