class PMachine (
    val stackHeight: Int,
    val codeLength: Int,
    val lexicalLevels: Int,
    val regFileSize: Int
) {
    val cpu = Cpu(1, 0, 0, 0)
    val registerFile = List(regFileSize) {_ -> Register(0)}
    val stack = MutableList(stackHeight) {_ -> 0}
    //val code = List(codeLength) {_ -> }
}