import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File




fun main() {

    val nbItems = 2000
    val nbSentencesByItem = 1000

    val sentences = extractSentences()
    val sortedWords = sortWordBySentenceEnabledCount(sentences, nbItems)
    val rawProgram = buildRawProgram(sortedWords, sentences, nbSentencesByItem)
    //val rawProgramStr = Json.encodeToString(rawProgram)
    //File("raw_program_dump_filterbadwords.json").writeText(rawProgramStr)

    val program = toProgram(rawProgram)
    val programStr = Json.encodeToString(program)

    File("learn_vn_from_fr.json").writeText(programStr)
}
