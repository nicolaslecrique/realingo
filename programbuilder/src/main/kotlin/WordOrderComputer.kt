

fun getSortedWordsByFrequency(sentencesDataset: List<SentenceInfo>, nbItems: Int): List<String> {
    val countByWord = mutableMapOf<String, Int>()
    for (sentence in sentencesDataset) {
        for (word in sentence.words) {
            val currentCount: Int = countByWord.getOrDefault(word.word_standard_format, 0)
            countByWord[word.word_standard_format] = currentCount + 1
        }
    }
    val sortedWords = countByWord.toList().sortedByDescending { it.second }.map { it.first }.take(nbItems)
    return sortedWords
}
