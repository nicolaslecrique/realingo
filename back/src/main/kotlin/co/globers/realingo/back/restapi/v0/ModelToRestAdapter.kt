package co.globers.realingo.back.restapi.v0

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

        fun toRest(program: LearningProgram): RestLearningProgram {
            return RestLearningProgram(
                uri = program.uri,
                originLanguageUri = program.originLanguageUri,
                learnedLanguageUri = program.learnedLanguageUri,
                lessons = program.lessons.map {
                    RestLessonInProgram(
                        uri = it.uri,
                        label = it.label)
                }
            )
        }

        fun toRest(lesson: Lesson): RestLesson {
            return RestLesson(
                uri = lesson.uri,
                label = lesson.label,
                sentences = lesson.sentences.map { s ->
                    RestSentence(
                        uri= s.uri,
                        sentence= s.sentence,
                        translation= s.translation,
                        hint= s.hint,
                        items = s.items.map {
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
                    )
                }
            )
        }


    }
}
