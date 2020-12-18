
fun sortWordBySentenceEnabledCount(sentencesDataset: List<SentenceWithTranslation>, nbWords: Int) :  List<String> {

    val sentences: List<Set<String>> = sentencesDataset.map { it.sentence.words_in_sentence.map { it.word_standard_format }.toSet() }
    val alreadyUsedWords = mutableSetOf<String>()
    val remainingWords = sentences.flatten().toMutableSet()
    val result = mutableListOf<String>()
    val remainingSentences = sentences.toMutableSet()

    while (alreadyUsedWords.size < nbWords) {

        val wordToCountSentence = mutableMapOf<String, MutableList<Set<String>>>()
        for (sentence in remainingSentences) { // loop over all remaining sentences
            val notAlreadyKnownWords = sentence subtract alreadyUsedWords
            if (notAlreadyKnownWords.size == 1) { // consider sentences that miss only one word
                val missingWord =
                    notAlreadyKnownWords.first(); // get the word that would allow this sentence to be known
                val currentListOfSentenceThisWord = wordToCountSentence.getOrDefault(missingWord, mutableListOf())
                currentListOfSentenceThisWord.add(sentence)
                wordToCountSentence[missingWord] = currentListOfSentenceThisWord
            }
        }

        val nextWordWithSentences = wordToCountSentence.maxByOrNull { it.value.count() }
        if (nextWordWithSentences == null){
            throw Exception("fuck")
        } else {
            alreadyUsedWords.add(nextWordWithSentences.key);
            remainingWords.remove(nextWordWithSentences.key)
            result.add(nextWordWithSentences.key)
            remainingSentences.removeAll(nextWordWithSentences.value)
        }
    }
    return result;
}

private fun getSortedWordsByFrequency(sentencesDataset: List<SentenceWithTranslation>, nbItems: Int): List<String> {
    val countByWord = mutableMapOf<String, Int>()
    for (sentence in sentencesDataset) {
        for (word in sentence.sentence.words_in_sentence) {
            val currentCount: Int = countByWord.getOrDefault(word.word_standard_format, 0)
            countByWord[word.word_standard_format] = currentCount + 1
        }
    }
    val sortedWords = countByWord.toList().sortedByDescending { it.second }.map { it.first }.take(nbItems)
    return sortedWords
}
