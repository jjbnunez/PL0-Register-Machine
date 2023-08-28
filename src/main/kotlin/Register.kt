class Register (value: Int) {
    private var data = value
    fun read(): Int {
        return this.data
    }
    fun write(value: Int) {
        data = value
    }
}