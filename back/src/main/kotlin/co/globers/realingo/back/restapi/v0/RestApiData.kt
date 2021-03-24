package co.globers.realingo.back.restapi.v0

import co.globers.realingo.back.model.Sentence

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

enum class RestExerciseType {
    translateToLearningLanguage,
    repeat
}

data class RestExercise(
    val exerciseType: RestExerciseType,
    val sentence: RestSentence
)

data class RestLesson(
    val uri: String,
    val label: String,
    val description: String,
    val exercises: List<RestExercise>
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
