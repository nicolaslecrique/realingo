import kotlinx.serialization.Serializable

private fun computeSentenceScoreForWord(sentence: SentenceInfo, wordToLean: WordInSentenceInfo): Float {

    val learnableWordProba = wordToLean.word_probability_in_sentence
    val sentenceProba = sentence.sentenceProbability
    val translationSimilarity = computeBackTranslationSimilarity(sentence.rawSentence, sentence.back_translation)

    return learnableWordProba * sentenceProba * translationSimilarity
}

private fun splitTextInSubWords(text: String): List<String>{
    return text.split("\\P{L}+".toRegex()).filter { it.isNotBlank() }
}

private fun isSentenceOkForWord(sentence: SentenceInfo, wordToLean: WordInSentenceInfo) : Boolean {
    // sentence ok if learned word is in back translation in identical form
    val wordToLearnInBackTranslation = sentence.back_translation.contains(wordToLean.word_raw_format)

    // and if all words are learnable
    val text = sentence.rawSentence

    // http://www.regular-expressions.info/unicode.html#prop
    // split in words or subwords
    val subWordsWholeSentence = text.split("\\P{L}+".toRegex())
        .filter { it.isNotBlank() }
        .joinToString()
    val subWordsByLearnableWords =
        sentence.words
            .map { it.word_raw_format }
            .flatMap { splitTextInSubWords(it) }
            .joinToString()

    val onlyLearnable = subWordsWholeSentence == subWordsByLearnableWords
    if (! onlyLearnable){
        println("not learnable sentence: '$text'")
    }

    return wordToLearnInBackTranslation && onlyLearnable
}

// compute number of words common between sentence and back translation
private fun computeBackTranslationSimilarity(sentence: String, backTranslation: String): Float {

    val sentenceSplit = sentence.split(' ').toSet()
    val backTranslationSplit = backTranslation.split(' ').toSet()
    val refSize = Integer.max(
        sentenceSplit.size,
        backTranslationSplit.size
    ) // we take max because sim < 1 if back translation add words
    return sentenceSplit.intersect(backTranslationSplit).size.toFloat() / refSize

}

private fun computeHint(sentence: SentenceInfo): String {

    // we fill words not in back translation
    val sentenceSplit = sentence.rawSentence.split(' ')
    val backTranslationSplit = sentence.back_translation.split(' ').toSet()

    return sentenceSplit.joinToString(" ") {
        if (backTranslationSplit.contains(it)) "_".repeat(it.length) else it
    }
}

@Serializable
data class SentenceWithWordToLean(
    val sentence: SentenceInfo,
    val wordToLean: WordInSentenceInfo,
    val hint: String,
    val score: Float
)

@Serializable
data class SentenceWithInfo(val sentence: SentenceWithWordToLean, val hint: String, val score: Float)

fun toProgram(rawProgram: RawProgram): LearningProgram {
    val result = rawProgram.itemsByWord
        .map {
            Item(
                it.first,
                it.second.map { s ->
                    Sentence(
                        s.sentence.rawSentence,
                        s.sentence.translation,
                        s.hint,
                        s.sentence.words.map { w ->
                            ItemInSentence(
                                //w.word_raw_format,
                                w.word_standard_format,
                                w.wordSensesUri,
                                w.min_index_in_sentence,
                                w.max_index_in_sentence
                            )
                        }
                        ) }
                    )
                }

    // TODO NICO DELETE
    val dict = rawProgram.wordSenses.map { ItemDictionaryEntry(it.wordSenseUri, listOf()) }

    return LearningProgram(result, ItemDictionary(dict))
}

@Serializable
data class RawProgram(
    val itemsByWord: List<Pair<String, List<SentenceWithWordToLean>>>,
    val wordSenses: List<WordSenseInfo>
)

fun buildRawProgram(
    sortedWordsToLearn: List<String>,
    programData: ProgramData,
    nbSentencesByItem: Int
): RawProgram {
    val setOfWordsToLearn = sortedWordsToLearn.toSet()

    val wordToRank = sortedWordsToLearn.mapIndexed { index, word -> word to index }.toMap()

    val sentences = programData.sentences

    val sentencesWithWordToLean = sentences
        .filter { s -> s.words.all { setOfWordsToLearn.contains(it.word_standard_format) } }
        .map { s ->
            val hardestWord = s.words.maxByOrNull { wordToRank.getValue(it.word_standard_format) }!!
            SentenceWithWordToLean(
                s,
                hardestWord,
                  computeHint(s),
                computeSentenceScoreForWord(s, hardestWord)
            )
        }

    // associate each sentence to its less frequent word in the sentence
    // then filter the 100 best sentences for each word
    val rawProgram = sentencesWithWordToLean
        .groupBy { s -> s.wordToLean.word_standard_format }
        .mapValues { pair ->

            val sortedOkSentences = pair.value
                .filter { isSentenceOkForWord(it.sentence, it.wordToLean) }
                .sortedByDescending { it.score }

            val withoutDupSentences = removeDuplicates(sortedOkSentences)
            val truncated = withoutDupSentences.take(nbSentencesByItem)
            truncated
        }
        .toList()
        .sortedBy { wordToRank.getValue(it.first) }

    val wordSensesUrisInProgram = rawProgram
        .flatMap { it.second }
        .flatMap { it.sentence.words }
        .flatMap { it.wordSensesUri }
        .toSet()

    val wordSensesInProgram = programData.wordSenses
        .filter { it.wordSenseUri in wordSensesUrisInProgram }

    return RawProgram(rawProgram, wordSensesInProgram)
}



private fun removeDuplicates(sortedSentences: List<SentenceWithWordToLean>): List<SentenceWithWordToLean> {
    val setUniqueSentences = mutableSetOf<String>()
    val setUniqueTranslations = mutableSetOf<String>()
    val result = mutableListOf<SentenceWithWordToLean>()
    for (sentence in sortedSentences){
        // two sentences are "identical" if they contains the same words to learn in the same order
        val sentenceKey = sentence.sentence
            .words
            .joinToString("_") { it.word_standard_format }

        val translation = sentence.sentence.translation

        if ( ! setUniqueSentences.contains(sentenceKey) &&
            ! setUniqueTranslations.contains(translation)){
            result.add(sentence)
            setUniqueSentences.add(sentenceKey)
            setUniqueTranslations.add(translation)
        }
    }
    return result
}
