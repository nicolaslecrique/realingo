package co.globers.realingo.back.restapi.v0

// ------ Language --------

data class RestLanguage(
    val uri: String,
    val label: String
)

// ------- Lesson -----------

data class RestItemTranslation(
    val translation: String,
    val englishDefinition: String
)

data class RestItemInSentence(
    val startIndex: Int,
    val endIndex: Int,
    val label: String,
    val translations: List<RestItemTranslation>
)

data class RestSentence(
    val uri: String,
    val sentence: String,
    val translation: String,
    val hint: String,
    val items: List<RestItemInSentence>
)

data class RestLesson(
    val uri: String,
    val label: String,
    val description: String,
    val sentences: List<RestSentence>
)

// --------- Program -----------

data class RestLessonInProgram(
    val uri: String,
    val label: String,
    val description: String,
)

data class RestLearningProgram(
    val uri: String,
    val originLanguageUri: String,
    val learnedLanguageUri: String,
    val lessons: List<RestLessonInProgram>
)
