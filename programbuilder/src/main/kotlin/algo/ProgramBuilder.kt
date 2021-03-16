package ProgramBuilderV2

import ProgramBuilderItem
import ProgramBuilderItemDictionary
import ProgramBuilderItemDictionaryDefinition
import ProgramBuilderItemDictionaryEntry
import ProgramBuilderItemInSentence
import ProgramBuilderLearningProgram
import ProgramBuilderSentence
import dataLoaders.DictLoader
import dataLoaders.DictionaryFromEnglish
import dataLoaders.ItemizedSentence
import dataLoaders.ItemizedSentencesLoader
import dataLoaders.SentencesTranslationLoader
import dataLoaders.TranslatedSentence
import poc.ItemToSentences
import poc.sortWordBySentenceEnabledCount


data class SentenceTranslatedItemized(
    val translation: TranslatedSentence,
    val itemized: ItemizedSentence
)

class ProgramBuilder {

    companion object {
        fun buildProgram() : ProgramBuilderLearningProgram {
            val translations = SentencesTranslationLoader.load("./language_data/vietnamese/open_subtitles_translated.jsonl")
            val itemized = ItemizedSentencesLoader.load("./language_data/vietnamese/itemized_sentences_vn.json")

            val dict = DictLoader.load("vi")
            val dictValidEntries = dict.entries
                .flatMap { it.translations.map { it.word } }
                .toSet()

            val validSentences = getValidSentences(itemized, translations)
            val itemToAllSentences = sortWordBySentenceEnabledCount(validSentences, 3000)

            val allowedItems = mutableSetOf<String>()

            val validItemsToSentences = itemToAllSentences
                .filter { it.item in dictValidEntries }
                .filter { itemToSentences ->
                    val nbSentencesOk = itemToSentences.sentences.count { sentence ->
                        // a sentence is ok if it doesn't contain item that has been removed
                        sentenceOkForItem(sentence, itemToSentences.item, allowedItems)
                    }
                    if (nbSentencesOk > 0){
                        allowedItems.add(itemToSentences.item)
                    }
                    nbSentencesOk > 0
                }
                .map { itemToSentences ->
                    val sentencesOk = itemToSentences.sentences
                        .filter {sentenceOkForItem(it, itemToSentences.item, allowedItems)}

                ItemToSentences(
                    itemToSentences.item,
                    sentencesOk // back translation must contain learned word
                )
            }


            val items = validItemsToSentences.map { itemToSentences ->
                ProgramBuilderItem(
                    itemStdFormat = itemToSentences.item,
                    sentences = itemToSentences.sentences.map { sentence ->
                        ProgramBuilderSentence(
                            sentence = sentence.itemized.sentence,
                            translation = sentence.translation.translated_sentence,
                            hint = computeHint(sentence),
                            itemsInSentence = sentence.itemized.items.map { itemizedSentenceItem ->
                                ProgramBuilderItemInSentence(
                                    itemStdForm = itemizedSentenceItem.item_std_format,
                                    startIndexInSentence = itemizedSentenceItem.min_index,
                                    endIndexInSentence = itemizedSentenceItem.max_index
                                )
                            }
                        )
                    }
                )
            }

            val itemDict = buildDictionary(dict, allowedItems)

            println("hello")
            return ProgramBuilderLearningProgram(items, itemDict)
        }


    }


}

val regex = "\\P{L}+".toRegex()



private fun buildDictionary(dict: DictionaryFromEnglish, items: Set<String>) : ProgramBuilderItemDictionary {

    val listEntries = dict.entries
        .flatMap { e -> e.translations.map { e to it } } // each entry / translation
        .groupBy { it.second.word }
        .filter { it.key in items }
        .map { wordToPair ->
            ProgramBuilderItemDictionaryEntry(
                itemStdForm = wordToPair.key,
                englishDefinitions = wordToPair.value.map {
                    ProgramBuilderItemDictionaryDefinition(
                        itemInEnglish = it.first.definition.word,
                        definitionInEnglish = it.first.definition.definition ?: "" + if (it.second.context != null) "[${it.second.context}]" else ""
                    )
                }
            )
        }

    return ProgramBuilderItemDictionary(listEntries)
}

private fun sentenceOkForItem(sentence: SentenceTranslatedItemized, itemStdFormat: String, usableItems: Set<String>): Boolean {
    val foundItem = sentence.itemized.items.first { it.item_std_format == itemStdFormat }
    val rawItem = sentence.itemized.sentence.substring(foundItem.min_index, foundItem.max_index + 1).toLowerCase()
    val itemFoundInBackTranslation = sentence.translation.back_translation.toLowerCase().contains(rawItem)
    val onlyUsableItems = sentence.itemized.items.all { it.item_std_format == itemStdFormat || it.item_std_format in usableItems }
    return itemFoundInBackTranslation && onlyUsableItems
}

private fun computeHint(sentence: SentenceTranslatedItemized): String {

    // we fill words not in back translation
    val originSentence = sentence.itemized.sentence.toLowerCase()
    val backTranslation = sentence.translation.back_translation.toLowerCase()

    val originSentenceSplit = originSentence.split(regex).filter { it.isNotBlank() }
    val backTranslationSplit = backTranslation.split(regex).filter { it.isNotBlank() }.toSet()

    // all "words" that are also in back translation are replaced by "_"
    var hint = originSentence
    for (elt in originSentenceSplit){
        if (backTranslationSplit.contains(elt)){
            hint = hint.replace(elt, "_".repeat(elt.length))
        }
    }
    return hint
}


private fun getValidSentences(
    itemized: List<ItemizedSentence>,
    translations: List<TranslatedSentence>
): List<SentenceTranslatedItemized> {

    val sentenceToItemizedDict = itemized.map { it.sentence to it }.toMap()

    val validSentences = translations
        .filter { sentenceToItemizedDict.containsKey(it.original_sentence) } // we can itemize the sentence
        .map { SentenceTranslatedItemized(it, sentenceToItemizedDict.getValue(it.original_sentence)) }
        .filter { it.translation.translation_score > 0.99 } // filter when translation score is too low
        .filter { it.itemized.items.isNotEmpty() } // remove empty sentences
        .filter { it.itemized.items.first().min_index == 0 } // remove sentence starting with "- "
        .filter { ! it.itemized.sentence.contains("..") }
        .filter { s -> // Most common word must not represent more that half the sentence.
            val maxByOrNull =
                s.itemized.items.groupingBy { it.item_std_format }.eachCount().maxByOrNull { it.value }
            if (maxByOrNull == null) {
                false
            } else {
                maxByOrNull.value == 1 || maxByOrNull.value * 2 < s.itemized.items.size
            }
        }// group items
        .groupBy { it.itemized.items.map { i -> i.item_std_format }.toSet() }
        .mapValues { it.value.maxByOrNull { s -> s.translation.translation_score }!! } // similar sentences (same words) => best translation score
        .values
        .toList()
    return validSentences
}
