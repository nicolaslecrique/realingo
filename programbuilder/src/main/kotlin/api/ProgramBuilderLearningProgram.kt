import kotlinx.serialization.Serializable

// this is what is serialized

@Serializable
data class ProgramBuilderItemDictionaryDefinition(
        val itemInEnglish: String,
        val definitionInEnglish: String
)

@Serializable
data class ProgramBuilderItemDictionaryEntry (
        val itemStdForm: String,
        val englishDefinitions: List<ProgramBuilderItemDictionaryDefinition>
        )


@Serializable
data class ProgramBuilderItemInSentence(
        val itemStdForm: String,
        val startIndexInSentence: Int,
        val endIndexInSentence: Int
)

@Serializable
data class ProgramBuilderItemDictionary(
        val entry: List<ProgramBuilderItemDictionaryEntry>
)

@Serializable
data class ProgramBuilderSentence(
        val sentence: String,
        val translation: String,
        val hint: String,
        val itemsInSentence: List<ProgramBuilderItemInSentence>
)

@Serializable
data class ProgramBuilderItem(
        val itemStdFormat: String,
        val sentences: List<ProgramBuilderSentence>
)


@Serializable
data class ProgramBuilderLesson(
        val items: List<ProgramBuilderItem>
)


@Serializable
data class ProgramBuilderLearningProgram(
        val items: List<ProgramBuilderItem>,
        val dictionary: ProgramBuilderItemDictionary
)
