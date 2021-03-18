package co.globers.realingo.back.services

import co.globers.realingo.back.dataloader.ProgramBuilderLearningProgram
import co.globers.realingo.back.dataloader.loadProgramFromFile
import co.globers.realingo.back.model.ItemInSentence
import co.globers.realingo.back.model.ItemTranslation
import co.globers.realingo.back.model.Language
import co.globers.realingo.back.model.LearningProgram
import co.globers.realingo.back.model.Lesson
import co.globers.realingo.back.model.Sentence
import co.globers.realingo.back.tools.generateUri

internal fun loadProgram(originLanguage: Language, learnedLanguage: Language): LearningProgram {

    val program = loadProgramFromFile(originLanguage, learnedLanguage)

    val programUri = generateUri("${learnedLanguage.uri}-from-${originLanguage.uri}-1")

    val lessons = loadLessons(program, programUri)

    return LearningProgram(
        programUri,
        originLanguage.uri,
        learnedLanguage.uri,
        lessons
    )
}

private val nbItemsByLesson = 3
private val nbSentencesByItem = 3

private fun loadLessons(program: ProgramBuilderLearningProgram, programUri: String): List<Lesson> {

    val dict = program.dictionary.entries

    val lessons = mutableListOf<Lesson>()
    var currentLessonSentences = mutableListOf<Sentence>()
    var currentLessonLabel = "Lesson 1"

    for ((currentItemIndex, item) in program.items.withIndex()) {
        if (currentItemIndex % nbItemsByLesson == nbItemsByLesson - 1) {
            lessons.add(
                Lesson(
                    uri = generateUri(currentLessonLabel, programUri),
                    label = currentLessonLabel,
                    sentences = currentLessonSentences
                )
            )
            currentLessonSentences = mutableListOf()
            currentLessonLabel = "Lesson ${lessons.size + 1}"
        } else {
            currentLessonSentences.addAll(
                item.sentences.take(nbSentencesByItem).mapIndexed { idx, s ->
                    Sentence(
                        uri = generateUri("$currentLessonLabel-item-$currentItemIndex-sent-$idx", programUri),
                        sentence = s.sentence,
                        translation = s.translation,
                        hint = s.hint,
                        items = s.itemsInSentence.map { item ->
                            ItemInSentence(
                                startIndex = item.startIndexInSentence,
                                endIndex = item.endIndexInSentence,
                                label = item.itemStdForm,
                                translations = dict.getValue(item.itemStdForm).map { def ->
                                    ItemTranslation(
                                        translation = def.itemInEnglish,
                                        englishDefinition = def.definitionInEnglish
                                    )
                                }
                            )
                        }
                    )
                }
            )
        }
    }
    return lessons
}

