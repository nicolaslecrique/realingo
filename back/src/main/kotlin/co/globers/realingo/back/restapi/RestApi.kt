package co.globers.realingo.back.restapi

import co.globers.realingo.back.services.Language
import co.globers.realingo.back.services.loadProgram
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

data class RestLanguage(
        val uri: String,
        val languageLabel: String
)

data class RestItemToLearn(
        val uri: String,
        val itemLabel: String,
)

data class RestLearningProgram(
        val uri: String,
        val originLanguageUri: String,
        val targetLanguageUri: String,
        val itemsToLearn: List<RestItemToLearn>
)

val availableOriginLanguages: List<RestLanguage> = listOf(
        toRestLanguage(Language.French)
)

val availableTargetLanguages: List<RestLanguage> = listOf(
        toRestLanguage(Language.Vietnamese),
        toRestLanguage(Language.English),
        toRestLanguage(Language.French),
        toRestLanguage(Language.Spanish)
)

fun toRestLanguage(language: Language): RestLanguage = RestLanguage(language.languageUri, language.languageLabel)


@RestController
class RestApi {

    @GetMapping("/available_origin_languages")
    suspend fun getAvailableOriginLanguages(
            @RequestParam(value = "target_language_uri") targetLanguageUri: String): List<RestLanguage> {
        return availableOriginLanguages
    }

    @GetMapping("/available_target_languages")
    suspend fun getAvailableTargetLanguages(): List<RestLanguage> {
        return availableTargetLanguages
    }

    @GetMapping("/program")
    suspend fun getProgram(
            @RequestParam(value = "target_language_uri") targetLanguageUri: String,
            @RequestParam(value = "origin_language_uri") originLanguageUri: String): RestLearningProgram {

        val originLanguage = Language.fromUri(originLanguageUri)
        val targetLanguage = Language.fromUri(targetLanguageUri)

        val program = loadProgram(originLanguage, targetLanguage)

        val uri = "${targetLanguageUri}-from-${originLanguageUri}-1"

        return RestLearningProgram(
                uri,
                originLanguageUri,
                targetLanguageUri,
                program.items.map { RestItemToLearn(it.itemString, it.itemUri) }
        )
    }


}
