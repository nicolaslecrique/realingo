package co.globers.realingo.back.restapi.v0

import co.globers.realingo.back.model.ExerciseType
import co.globers.realingo.back.model.Language
import co.globers.realingo.back.model.LearningProgram
import co.globers.realingo.back.model.Lesson

class ModelToRestAdapter {

    companion object {

        fun toRest(language: Language): RestLanguage {
            return RestLanguage(
                uri = language.uri,
                label = language.label
            )
        }

        fun toRest(exerciseType: ExerciseType): RestExerciseType {
            return when(exerciseType){
                ExerciseType.TranslateToLearningLanguage -> RestExerciseType.TranslateToLearningLanguage
                ExerciseType.Repeat -> RestExerciseType.Repeat
            }
        }

        fun toRest(program: LearningProgram): RestLearningProgram {
            return RestLearningProgram(
                uri = program.uri,
                originLanguageUri = program.originLanguageUri,
                learnedLanguageUri = program.learnedLanguageUri,
                lessons = program.lessons.map {
                    RestLessonInProgram(
                        uri = it.uri,
                        label = it.label,
                        description = it.description
                    )
                }
            )
        }

        fun toRest(lesson: Lesson): RestLesson {
            return RestLesson(
                uri = lesson.uri,
                label = lesson.label,
                description = lesson.description,
                exercises = lesson.exercises.map { e ->
                    RestExercise(
                        sentence= RestSentence(
                        uri= e.sentence.uri,
                        sentence= e.sentence.sentence,
                        translation= e.sentence.translation,
                        hint= e.sentence.hint,
                        items = e.sentence.items.map {
                            RestItemInSentence(
                                startIndex = it.startIndex,
                                endIndex = it.endIndex,
                                label = it.label,
                                translations = it.translations.map { t ->
                                    RestItemTranslation(
                                        translation = t.translation,
                                        englishDefinition = t.englishDefinition
                                    )
                                }
                            )
                        }
                    ),
                        exerciseType = toRest(e.exerciseType)
                    )
                }
            )
        }


    }
}
