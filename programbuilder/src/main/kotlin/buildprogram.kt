import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File



// plan: extract dict associé au program
// => chaque mot du program est associé à une URI du mot dans le dico
// => match sur le standard-word
// => les phrases du programme qui contiennent des mots pas dans le dico sont filtrés
// => le dico est intégré dans l'objet program qui est exporté


fun main() {

    val nbItems = 2000
    val nbSentencesByItem = 1000

    val programData = extractProgramData()
    val sortedWords = getSortedWordsByFrequency(programData.sentences, nbItems)
    val rawProgram = buildRawProgram(
        sortedWords, programData, nbSentencesByItem)
    //val rawProgramStr = Json.encodeToString(rawProgram)
    //File("raw_program_dump_filterbadwords.json").writeText(rawProgramStr)

    val program = toProgram(rawProgram)
    val programStr = Json.encodeToString(program)

    File("learn_vn_from_fr.json").writeText(programStr)
}

