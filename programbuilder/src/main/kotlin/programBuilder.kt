import kotlinx.serialization.Serializable

private fun computeSentenceScoreForWord(sentence: SentenceWithWordToLean): Float {

    val learnableWordProba = sentence.wordToLean.word_probability_in_sentence
    val sentenceProba = sentence.sentence.sentence.sentence_probability
    val translationSimilarity = computeBackTranslationSimilarity(sentence.sentence)

    return learnableWordProba * sentenceProba * translationSimilarity
}

private fun splitTextInSubWords(text: String): List<String>{
    return text.split("\\P{L}+".toRegex()).filter { it.isNotBlank() }
}

private fun isSentenceOkForWord(sentence: SentenceWithWordToLean) : Boolean {
    // sentence ok if learned word is in back translation in identical form

    val wordToLearnInBackTranslation = sentence.sentence.translation.back_translation
        .contains(sentence.wordToLean.word_raw_format)

    val text = sentence.sentence.sentence.raw_sentence

    // http://www.regular-expressions.info/unicode.html#prop
    // split in words or subwords
    val subWordsWholeSentence = text.split("\\P{L}+".toRegex())
        .filter { it.isNotBlank() }
        .joinToString()
    val subWordsByLearnableWords =
        sentence.sentence.sentence.words_in_sentence
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
private fun computeBackTranslationSimilarity(sentence: SentenceWithTranslation): Float {

    val sentenceSplit = sentence.sentence.raw_sentence.split(' ').toSet()
    val backTranslationSplit = sentence.translation.back_translation.split(' ').toSet()
    val refSize = Integer.max(
        sentenceSplit.size,
        backTranslationSplit.size
    ) // we take max because sim < 1 if back translation add words
    return sentenceSplit.intersect(backTranslationSplit).size.toFloat() / refSize

}

private fun computeHint(sentence: SentenceWithWordToLean): String {

    // we fill words not in back translation
    val sentenceSplit = sentence.sentence.sentence.raw_sentence.split(' ')
    val backTranslationSplit = sentence.sentence.translation.back_translation.split(' ').toSet()

    return sentenceSplit.joinToString(" ") {
        if (backTranslationSplit.contains(it)) "_".repeat(it.length) else it
    }
}

@Serializable
data class SentenceWithWordToLean(val sentence: SentenceWithTranslation, val wordToLean: WordInSentenceInData)

@Serializable
data class SentenceWithInfo(val sentence: SentenceWithWordToLean, val hint: String, val score: Float)

fun toProgram(rawProgram: RawProgram): LearningProgram {
    val result = rawProgram.itemsByWord
        .map {
            Item(
                it.first,
                it.second.map { s ->
                    Sentence(
                        s.sentence.sentence.sentence.raw_sentence,
                        s.sentence.sentence.translation.translated_sentence,
                        s.hint
                    )
                }
            )
        }
    return LearningProgram(result)
}

@Serializable
data class RawProgram(val itemsByWord: List<Pair<String, List<SentenceWithInfo>>>)

fun buildRawProgram(
    sortedWordsToLearn: List<String>,
    sentences: List<SentenceWithTranslation>,
    nbSentencesByItem: Int
): RawProgram {
    val setOfWordsToLearn = sortedWordsToLearn.toSet()

    val wordToRank = sortedWordsToLearn.mapIndexed { index, word -> word to index }.toMap()

    val sentencesWithWordToLean = sentences
        .filter { s -> s.sentence.words_in_sentence.all { setOfWordsToLearn.contains(it.word_standard_format) } }
        .map { s ->
            SentenceWithWordToLean(
                s,
                s.sentence.words_in_sentence.maxByOrNull { wordToRank.getValue(it.word_standard_format) }!!
            )
        }
        .map { s ->
            SentenceWithInfo(s, computeHint(s), computeSentenceScoreForWord(s))
        }

    // associate each sentence to its less frequent word in the sentence
    // then filter the 100 best sentences for each word
    val rawProgram = sentencesWithWordToLean
        .groupBy { s -> s.sentence.wordToLean.word_standard_format }
        .mapValues { pair ->

            val sortedOkSentences = pair.value
                .filter { isSentenceOkForWord(it.sentence) }
                .sortedByDescending { it.score }

            val withoutDupSentences = removeDuplicates(sortedOkSentences)
            val truncated = withoutDupSentences.take(nbSentencesByItem)
            truncated
        }
        .toList()
        .sortedBy { wordToRank.getValue(it.first) }
    return RawProgram(rawProgram)
}

private fun removeDuplicates(sortedSentences: List<SentenceWithInfo>): List<SentenceWithInfo> {
    val setUniqueSentences = mutableSetOf<String>()
    val setUniqueTranslations = mutableSetOf<String>()
    val result = mutableListOf<SentenceWithInfo>()
    for (sentence in sortedSentences){
        // two sentences are "identical" if they contains the same words to learn in the same order
        val sentenceKey = sentence.sentence.sentence.sentence
            .words_in_sentence
            .joinToString("_") { it.word_standard_format }

        val translation = sentence.sentence.sentence.translation.translated_sentence

        if ( ! setUniqueSentences.contains(sentenceKey) &&
            ! setUniqueTranslations.contains(translation)){
            result.add(sentence)
            setUniqueSentences.add(sentenceKey)
            setUniqueTranslations.add(translation)
        }
    }
    return result
}
