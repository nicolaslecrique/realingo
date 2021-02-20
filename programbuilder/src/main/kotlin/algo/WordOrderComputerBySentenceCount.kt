package poc

import ProgramBuilderV2.SentenceTranslatedItemized

data class ItemToSentences (
    val item: String,
    val sentences: List<SentenceTranslatedItemized>
    )

data class SentenceWithSetOfItem(
    val sentence: SentenceTranslatedItemized,
    val items: Set<String>
)

fun sortWordBySentenceEnabledCount(sentencesDataset: List<SentenceTranslatedItemized>, nbWords: Int) :  List<ItemToSentences> {

    val sentencesWithSet = sentencesDataset.map {
        SentenceWithSetOfItem(it, it.itemized.items.map { it.item_std_format }.toSet()) }

    val alreadyUsedWords = mutableSetOf<String>()
    val remainingWords = sentencesWithSet.map { it.items }.flatten().toMutableSet()
    val result = mutableListOf<ItemToSentences>()
    val remainingSentences = sentencesWithSet.toMutableSet()

    while (alreadyUsedWords.size < nbWords) {

        val wordToCountSentence = mutableMapOf<String, MutableList<SentenceWithSetOfItem>>()
        for (sentence in remainingSentences) { // loop over all remaining sentences
            val notAlreadyKnownWords = sentence.items subtract alreadyUsedWords
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
            throw Exception("Cas not managed: no single word enable more sentences, we must manage case to add two words at a time")
        } else {
            alreadyUsedWords.add(nextWordWithSentences.key);
            remainingWords.remove(nextWordWithSentences.key)
            result.add(ItemToSentences(nextWordWithSentences.key, nextWordWithSentences.value.map { it.sentence }))
            remainingSentences.removeAll(nextWordWithSentences.value)
        }
    }
    return result;
}
