package ProgramBuilderV2

import algo.ProgramBuilder
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File

fun main() {

    val program = ProgramBuilder.buildProgram()
    val programStr = Json.encodeToString(program)
    File("program_vn_from_en.json").writeText(programStr)
}
