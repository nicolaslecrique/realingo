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

class FileLoader {

    companion object {
        fun getFileFromResource(fileName: String): File {
            val classLoader: ClassLoader = FileLoader::class.java.classLoader
            val resource: URL = classLoader.getResource(fileName)!!
            return File(resource.toURI())
        }
    }

}


fun main() {

    val languageDataStr = FileLoader.getFileFromResource("./language_data/vietnamese/language_data.json").readText()
    val languageData = Json.decodeFromString<LanguageData>(languageDataStr)
    println("Hello World")
}
