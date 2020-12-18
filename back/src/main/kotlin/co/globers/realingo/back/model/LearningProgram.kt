package co.globers.realingo.back.model


data class Sentence(
    val uri: String,
    val sentence: String,
    val translation: String,
    val hint: String
)

data class ItemToLearn(
    val uri: String,
    val label: String,
    val sentences: List<Sentence>
)

data class LearningProgram(
    val uri: String,
    val originLanguageUri: String,
    val learnedLanguageUri: String,
    val itemsToLearn: List<ItemToLearn>
)
