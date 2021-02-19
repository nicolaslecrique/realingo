import dataLoaders.LanguageDataLoader
import dataLoaders.SentencesTranslationLoader
import kotlinx.serialization.Serializable

@Serializable
data class WordSenseInfo(
    val wordSenseUri: String,
    val wordInEnglish: String,
    val translations: List<String>
)

@Serializable
data class WordInSentenceInfo (
    val word_raw_format: String,
    val word_standard_format: String,
    val min_index_in_sentence: Int,
    val max_index_in_sentence: Int,
    val word_probability_in_sentence: Float,
    val wordSensesUri: List<String>
)

@Serializable
data class SentenceInfo(
    val rawSentence: String,
    val sentenceProbability: Float,
    val translation: String,
    val back_translation: String,
    val words: List<WordInSentenceInfo>
)

@Serializable
data class ProgramData(
    val sentences: List<SentenceInfo>,
    val wordSenses: List<WordSenseInfo>
)

fun extractProgramData() : ProgramData {
    val languageData = LanguageDataLoader.load("./language_data/vietnamese/language_data_vietnamese_100000.json")
    val translations = SentencesTranslationLoader.load("./language_data/vietnamese/translation_vn_fr_100000.json")
    val dict = BilingualDictBuilder.load("vi", "fr")

    val translationMap = translations.associateBy { it.original_sentence }
    val wordSenseMap = dict.entries
        .groupBy { it.key.word }
        .mapValues { p -> p.value.flatMap { it.value }}
        .mapValues { l -> l.value.map { entry ->
            WordSenseInfo(
                "${entry.definition.word}-${entry.definition.type}-${entry.definition.definition}",
                entry.definition.word,
                entry.translations.map { it.word }
            )
        } }
    // one word str -> several words (diff by genre, number...) -> several DictEntry for each word
    // the merge str -> several Dict Entry

    var nbSentencesOk = 0
    var nbSentencesWithWordMissing = 0
    var nbSentencesByMissingWord = mutableMapOf<String,Int>()
    val sentences = languageData.sentences
        .mapNotNull { s ->
            val rawSentence = s.raw_sentence
            val sentenceProba = s.sentence_probability
            val translated = translationMap[rawSentence]
            val wordSenses = s.words_in_sentence.map {
                val senses = wordSenseMap[it.word_standard_format]
                it to senses
            }
            if ( translated == null || wordSenses.any { it.second == null }){
                nbSentencesWithWordMissing++
                println("sentence skipped '$rawSentence' because of word '${wordSenses.filter { it.second == null }.map { it.first.word_standard_format }}'")
                for (word in wordSenses.filter { it.second == null }){
                    nbSentencesByMissingWord.putIfAbsent(word.first.word_standard_format, 0)
                    nbSentencesByMissingWord[word.first.word_standard_format] = nbSentencesByMissingWord[word.first.word_standard_format] !! + 1
                }
                null
            } else {
                nbSentencesOk++
                val translation = translated.translated_sentence
                val backTranslation = translated.back_translation
                SentenceInfo(
                    rawSentence,
                    sentenceProba,
                    translation,
                    backTranslation,
                    wordSenses.map { pair ->
                        WordInSentenceInfo(
                            pair.first.word_raw_format,
                            pair.first.word_standard_format,
                            pair.first.min_index_in_sentence,
                            pair.first.max_index_in_sentence,
                            pair.first.word_probability_in_sentence,
                            pair.second!!.map { it.wordSenseUri }
                        )
                    }
                )
            }
        }

    val sortedByDescending = nbSentencesByMissingWord.toList().sortedByDescending { it.second }

    val allUsedSenseUris = sentences
        .flatMap { it.words }
        .flatMap { it.wordSensesUri }
        .toSet()

    val wordSenses = wordSenseMap
        .flatMap { it.value }
        .toSet()
        .filter { it.wordSenseUri in allUsedSenseUris }

    return ProgramData(sentences, wordSenses)
}
