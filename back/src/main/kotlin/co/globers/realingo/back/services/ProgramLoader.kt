package co.globers.realingo.back.services

import co.globers.realingo.back.model.ItemToLearn
import co.globers.realingo.back.model.LearningProgram
import co.globers.realingo.back.model.Sentence
import co.globers.realingo.back.tools.FileLoader
import co.globers.realingo.back.tools.generateUri
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

@Serializable
data class ProgramBuilderSentence(
        val sentence: String,
        val translation: String,
        val hint: String
)

@Serializable
data class ProgramBuilderItem(
        val itemString: String,
        val sentences: List<ProgramBuilderSentence>
)

@Serializable
data class ProgramBuilderLearningProgram(
        val items: List<ProgramBuilderItem>
)


fun loadProgramFromFile(originLanguage: Language, learnedLanguage: Language): ProgramBuilderLearningProgram {
    val filename = "program_${learnedLanguage.shortCode}_from_${originLanguage.shortCode}.json"
    val programStr = FileLoader.getFileFromResource("programs/${filename}").readText()
    val program = Json.decodeFromString<ProgramBuilderLearningProgram>(programStr)
    return program
}


internal fun loadProgram(originLanguage: Language, learnedLanguage: Language): LearningProgram {

    val program = loadProgramFromFile(originLanguage, learnedLanguage)

    val programUri = generateUri("${learnedLanguage.uri}-from-${originLanguage.uri}-1")

    return LearningProgram(
        programUri,
        originLanguage.uri,
        learnedLanguage.uri,
        program.items.map {
            val itemUri = generateUri(it.itemString, programUri)
            ItemToLearn(
                itemUri,
                it.itemString,
                it.sentences
                    .map { s -> Sentence(generateUri(s.sentence, itemUri), s.sentence, s.translation, s.hint) }
            ) }
    )
}

