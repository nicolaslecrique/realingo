package co.globers.realingo.back.model

data class ItemTranslation(
    val translation: String,
    val englishDefinition: String
)

data class ItemInSentence(
    val startIndex: Int,
    val endIndex: Int,
    val label: String,
    val translations: List<ItemTranslation>
)

data class Sentence(
    val uri: String,
    val sentence: String,
    val translation: String,
    val hint: String,
    val items: List<ItemInSentence>
)

data class Lesson(
    val uri: String,
    val label: String,
    val sentences: List<Sentence>
)

data class LearningProgram(
    val uri: String,
    val originLanguageUri: String,
    val learnedLanguageUri: String,
    val lessons: List<Lesson>
)
