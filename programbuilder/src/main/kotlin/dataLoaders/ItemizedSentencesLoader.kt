package dataLoaders

import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json


@Serializable
data class ItemizedSentenceItem(
    val item_std_format: String,
    val min_index : Int,
    val max_index : Int
)

@Serializable
data class ItemizedSentence(
    val sentence: String,
    val sentence_std_format: String,
    val items: List<ItemizedSentenceItem>
)

@Serializable
data class ItemizedSentences(
    val sentences: List<ItemizedSentence>
)


class ItemizedSentencesLoader {

    companion object {
        fun load(filePath: String): List<ItemizedSentence> {
            val sentences = FileLoader.getFileFromResource(filePath).readText()
            val itemizedSentences = Json.decodeFromString<ItemizedSentences>(sentences)
            return itemizedSentences.sentences
        }
    }

}
