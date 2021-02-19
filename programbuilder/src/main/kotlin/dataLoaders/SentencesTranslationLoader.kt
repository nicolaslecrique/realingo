package dataLoaders

import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

@Serializable
data class TranslatedSentence(
    val original_sentence: String,
    val translated_sentence: String,
    val back_translation: String,
    val translation_score: Double
)


class SentencesTranslationLoader {

    companion object {
        fun load(filePath: String): List<TranslatedSentence> {
            val translationsStr = FileLoader.getFileFromResource(filePath).readLines()
            val translations = translationsStr.map { Json.decodeFromString<TranslatedSentence>(it) }
            return translations
        }
    }
}
