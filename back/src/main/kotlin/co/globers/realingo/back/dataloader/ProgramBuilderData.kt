package co.globers.realingo.back.dataloader

import kotlinx.serialization.Serializable

// DO NOT CHANGE ! Keep in sync
// copy past from ProgramBuilderLearningProgram in programbuilder project

@Serializable
data class ProgramBuilderItemDictionaryDefinition(
    val itemInEnglish: String,
    val definitionInEnglish: String
)

@Serializable
data class ProgramBuilderItemInSentence(
    val itemStdForm: String,
    val startIndexInSentence: Int,
    val endIndexInSentence: Int
)

@Serializable
data class ProgramBuilderItemDictionary(
    val entries: Map<String, List<ProgramBuilderItemDictionaryDefinition>>
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
data class ProgramBuilderLearningProgram(
    val items: List<ProgramBuilderItem>,
    val dictionary: ProgramBuilderItemDictionary
)
