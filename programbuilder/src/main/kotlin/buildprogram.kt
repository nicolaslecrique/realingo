import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
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

fun computeScore(sentence: SentenceData, learnableWord: String) =
    sentence.sentence_probability * sentence.words_in_sentence.first { it.word_standard_format == learnableWord }.word_probability_in_sentence


fun main() {

    val nbItems = 2000
    val nbSentencesByItem = 10

    val languageDataStr = FileLoader.getFileFromResource("./language_data/vietnamese/language_data_vietnamese_100000.json").readText()
    val languageData = Json.decodeFromString<LanguageData>(languageDataStr)

    val translationsStr = FileLoader.getFileFromResource("./language_data/vietnamese/translation_vn_fr_100000.json").readText()
    val translations = Json.decodeFromString<SentencesTranslation>(translationsStr)
    val translationMap = translations.translated_sentences.associateBy { it.original_sentence }

    val countByWord = mutableMapOf<String,Int>()
    for (sentence in languageData.sentences){
        for (word in sentence.words_in_sentence){
            val currentCount: Int = countByWord.getOrDefault(word.word_standard_format, 0)
            countByWord[word.word_standard_format] = currentCount + 1
        }
    }
    // associate each sentence to its less frequent word in the sentence
    // then filter the 100 best sentences for each word
    val learnableWordToItem = languageData.sentences
        .groupBy { sentence -> sentence.words_in_sentence.map { it.word_standard_format }.minByOrNull{ countByWord.getValue(it) }!! }
        .mapValues { pair ->
            val keptSentences = pair.value.sortedBy { -computeScore(it,pair.key) }.take(nbSentencesByItem)
            val sentences = keptSentences.map { Sentence(it.raw_sentence, translationMap.getValue(it.raw_sentence).translated_sentence) }
            Item(pair.key, pair.key, sentences)
         }
            .values

    val sortedItems = learnableWordToItem.toList().sortedByDescending { countByWord.getValue(it.itemUri) }.take(nbItems)

    sortedItems.forEachIndexed { index, it ->
        println(index.toString() + "-" + it.itemString + "-" + it.sentences.count())
    }

    val program = LearningProgram(sortedItems)
    val programStr = Json.encodeToString(program)

    File("learn_vn_from_fr_100k_program.json").writeText(programStr)



    // 1) faire la table de frequence des mots
    // 2) associer à chaque mot ses phrases
    // 3) trier les phrases par qualité

}
