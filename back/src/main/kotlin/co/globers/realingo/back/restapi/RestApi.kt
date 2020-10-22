package co.globers.realingo.back.restapi

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

data class Language(
        val languageUri: String,
        val languageLabel: String
)

val availableOriginLanguages: List<Language> = listOf(
        Language("french", languageLabel = "French")
)

val availableTargetLanguages: List<Language> = listOf(
        Language("vietnamese", languageLabel = "Vietnamese"),
        Language("english", languageLabel = "English"),
        Language("french", languageLabel = "French"),
        Language("spanish", languageLabel = "Spanish")
)

@RestController
class RestApi {

    @GetMapping("/available_origin_languages")
    suspend fun getAvailableOriginLanguages(): List<Language> {
        return availableOriginLanguages
    }

    @GetMapping("/available_target_languages")
    suspend fun getAvailableTargetLanguages(): List<Language> {
        return availableTargetLanguages
    }

}
