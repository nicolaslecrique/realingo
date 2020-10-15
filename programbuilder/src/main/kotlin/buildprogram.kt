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

fun computeScore(sentence: SentenceData, learnableWord: String) =
    sentence.sentence_probability * sentence.words_in_sentence.first { it.word_standard_format == learnableWord }.word_probability_in_sentence


fun main() {

    val languageDataStr = FileLoader.getFileFromResource("./language_data/vietnamese/language_data_10000.json").readText()
    val languageData = Json.decodeFromString<LanguageData>(languageDataStr)

    val countByWord = mutableMapOf<String,Int>()
    for (sentence in languageData.sentences){
        for (word in sentence.words_in_sentence){
            val currentCount: Int = countByWord.getOrDefault(word.word_standard_format, 0)
            countByWord[word.word_standard_format] = currentCount + 1
        }
    }
    // associate each sentence to its less frequent word in the sentence
    // then filter the 100 best sentences for each word
    val learnableWordToSentences = languageData.sentences
        .groupBy { sentence -> sentence.words_in_sentence.map { it.word_standard_format }.minByOrNull{ countByWord.getValue(it) }!! }
        .mapValues { pair -> pair.value.sortedBy { -computeScore(it,pair.key) }.take(100) }





    // 1) faire la table de frequence des mots
    // 2) associer à chaque mot ses phrases
    // 3) trier les phrases par qualité


    println("Hello World")
}
