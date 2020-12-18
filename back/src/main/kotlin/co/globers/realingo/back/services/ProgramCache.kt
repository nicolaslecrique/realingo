package co.globers.realingo.back.services

import co.globers.realingo.back.model.LearningProgram
import org.springframework.stereotype.Service

data class ProgramKey(val learnedLanguage: Language, val originLanguage: Language)

@Service
class ProgramCache {

    val availableOriginLanguages: List<Language> = listOf(
        Language.French
    )

    val availableLearnedLanguages: List<Language> = listOf(
        Language.Vietnamese
    )

    private val availablePrograms = listOf(
        ProgramKey(Language.Vietnamese, Language.French)
    )

    val programs: Map<ProgramKey, LearningProgram> = availablePrograms
        .map { it to loadProgram(it.originLanguage, it.learnedLanguage) }
        .toMap()
}
