package co.globers.realingo.back.services

import co.globers.realingo.back.model.Language
import co.globers.realingo.back.model.LearningProgram
import org.springframework.stereotype.Service

data class ProgramKey(val learnedLanguage: Language, val originLanguage: Language)

@Service
class ProgramCache {

    val availableOriginLanguages: List<Language> = listOf(
        Language.English
    )

    val availableLearnedLanguages: List<Language> = listOf(
        Language.Vietnamese
    )

    private val vnFromEnglishProgram = loadProgram(
        learnedLanguage = Language.Vietnamese,
        originLanguage = Language.English
    )

    val availablePrograms = mapOf(
        ProgramKey(
            learnedLanguage = Language.Vietnamese,
            originLanguage= Language.English) to vnFromEnglishProgram.uri
    )

    val programsByUri = mapOf(
        vnFromEnglishProgram.uri to vnFromEnglishProgram
    )


}
