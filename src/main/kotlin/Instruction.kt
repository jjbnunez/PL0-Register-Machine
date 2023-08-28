class Instruction (
    val token1: Int,
    val token2: Int,
    val token3: Int,
    val token4: Int
) {
    val opCode = OpCode.entries.toTypedArray().getOrElse(token1) { OpCode.ERR }
    val r = token2
    val l = token3
    val m = token4
}