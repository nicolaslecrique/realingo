package co.globers.realingo.back.services

import co.globers.realingo.back.tools.FileLoader
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

@Serializable
data class Sentence(
        val sentence: String,
        val translation: String,
        val hint: String
)

@Serializable
data class Item(
        val itemString: String,
        val sentences: List<Sentence>
)

@Serializable
data class LearningProgram(
        val items: List<Item>
)


fun loadProgram(originLanguage: Language, targetLanguage: Language): LearningProgram {
    val filename = "program_${targetLanguage.shortCode}_from_${originLanguage.shortCode}.json"
    val programStr = FileLoader.getFileFromResource("programs/${filename}").readText()
    val program = Json.decodeFromString<LearningProgram>(programStr)
    return program
}
