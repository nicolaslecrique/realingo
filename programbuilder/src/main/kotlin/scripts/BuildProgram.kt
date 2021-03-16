package ProgramBuilderV2

import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File

fun main() {

    val program = ProgramBuilder.buildProgram()
    val programStr = Json.encodeToString(program)
    File("learn_vn_from_fr_v2.json").writeText(programStr)
}
