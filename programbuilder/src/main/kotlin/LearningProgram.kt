import kotlinx.serialization.Serializable



@Serializable
data class ItemDictionaryDefinition(
        val itemInEnglish: String,
        val definitionInEnglish: String
)

@Serializable
data class ItemDictionaryEntry (
        val itemStdForm: String,
        val englishDefinitions: List<ItemDictionaryDefinition>
        )


@Serializable
data class ItemInSentence(
        val itemStdForm: String,
        val startIndexInSentence: Int,
        val endIndexInSentence: Int
)

@Serializable
data class ItemDictionary(
        val entry: List<ItemDictionaryEntry>
)

@Serializable
data class Sentence(
        val sentence: String,
        val translation: String,
        val hint: String,
        val itemsInSentence: List<ItemInSentence>
)

@Serializable
data class Item(
        val itemStdFormat: String,
        val sentences: List<Sentence>
)

@Serializable
data class LearningProgram(
        val items: List<Item>,
        val dictionary: ItemDictionary
)
