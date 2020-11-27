import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json


data class SentencesWithWords(val sentences: String, val words: Set<String>)
data class WordWithSentences(val word: String, val sentences: List<SentencesWithWords>)

fun sortWords(sentences: List<SentencesWithWords>, nbWords: Int) :  List<WordWithSentences> {

    val alreadyUsedWords = mutableSetOf<String>()
    val remainingWords = sentences.flatMap { it.words }.toMutableSet()
    val result = mutableListOf<WordWithSentences>()
    val remainingSentences = sentences.toMutableSet()

    while (alreadyUsedWords.size < nbWords){

        val wordToSentences = mutableMapOf<String,MutableList<SentencesWithWords>>()
        for (sentence in remainingSentences){ // loop over all remaining sentences
            val notAlreadyKnownWords = sentence.words subtract alreadyUsedWords
            if (notAlreadyKnownWords.size == 1){ // consider sentences that miss only one word
                val missingWord = notAlreadyKnownWords.first(); // get the word that would allow this sentence to be known
                if (!wordToSentences.containsKey(missingWord)){
                    wordToSentences[missingWord] = mutableListOf(sentence)
                } else {
                    wordToSentences[missingWord]!!.add(sentence)
                }
            }
        }

        val nextWordWithSentences = wordToSentences.maxByOrNull { it.value.size }
        if (nextWordWithSentences == null){
            throw Exception("fuck")
        } else {
            alreadyUsedWords.add(nextWordWithSentences.key);
            remainingWords.remove(nextWordWithSentences.key)
            result.add(WordWithSentences(nextWordWithSentences.key, nextWordWithSentences.value))
            remainingSentences.removeAll(nextWordWithSentences.value)
        }
    }
    return result;

}

fun main() {

    val languageDataStr = FileLoader.getFileFromResource("./language_data/vietnamese/language_data_vietnamese_100000.json").readText()
    val languageData: LanguageData = Json.decodeFromString<LanguageData>(languageDataStr)

    val sentences = languageData.sentences.map { SentencesWithWords(it.raw_sentence, it.words_in_sentence.map { w -> w.word_standard_format }.toSet()) }

    val result = sortWords(sentences, 1000)

    print(result)


}
