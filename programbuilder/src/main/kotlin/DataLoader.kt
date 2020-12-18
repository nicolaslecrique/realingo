import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import java.io.File
import java.net.URL

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

@Serializable
data class TranslatedSentence(
    val original_sentence: String,
    val translated_sentence: String,
    val back_translation: String,
    val confidence: Float  // number between zero and one, for now: one if back-translation is equals to original sentence
)

@Serializable
data class SentencesTranslation(
    val translated_sentences: List<TranslatedSentence>
)


class FileLoader {

    companion object {
        fun getFileFromResource(fileName: String): File {
            val classLoader: ClassLoader = FileLoader::class.java.classLoader
            val resource: URL = classLoader.getResource(fileName)!!
            return File(resource.toURI())
        }
    }

}

@Serializable
data class SentenceWithTranslation(val sentence: SentenceData, val translation: TranslatedSentence)

fun extractSentences() : List<SentenceWithTranslation> {
    val languageDataStr = FileLoader.getFileFromResource("./language_data/vietnamese/language_data_vietnamese_100000.json").readText()
    val languageData = Json.decodeFromString<LanguageData>(languageDataStr)

    val translationsStr = FileLoader.getFileFromResource("./language_data/vietnamese/translation_vn_fr_100000.json").readText()
    val translations = Json.decodeFromString<SentencesTranslation>(translationsStr)
    val translationMap = translations.translated_sentences.associateBy { it.original_sentence }

    val sentencesWithTranslation = languageData.sentences
        .map { SentenceWithTranslation(it, translationMap.getValue(it.raw_sentence)) }

    return sentencesWithTranslation
}
