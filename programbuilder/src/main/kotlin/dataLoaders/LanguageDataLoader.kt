package dataLoaders

import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

@Serializable
data class WordInSentenceInData(
    val word_standard_format: String,
    val word_raw_format: String,
    val min_index_in_sentence: Int,
    val max_index_in_sentence: Int,
    val word_probability_in_sentence: Float
)

@Serializable
data class SentenceData(
    val raw_sentence: String,
    val words_in_sentence: List<WordInSentenceInData>,
    val sentence_probability: Float
)

@Serializable
data class LanguageData(
    val sentences: List<SentenceData>
)

class LanguageDataLoader {

    companion object {
        fun load(filePath: String): LanguageData {
            val languageDataStr = FileLoader.getFileFromResource(filePath).readText()
            val languageData = Json.decodeFromString<LanguageData>(languageDataStr)
            return languageData
        }
    }
}
