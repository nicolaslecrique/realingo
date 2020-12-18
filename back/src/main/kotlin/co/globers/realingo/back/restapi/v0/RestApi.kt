package co.globers.realingo.back.restapi.v0

import co.globers.realingo.back.services.Language
import co.globers.realingo.back.services.loadProgram
import co.globers.realingo.back.tools.generateUri
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

data class RestLanguage(
        val uri: String,
        val label: String
)


data class RestSentence(
        val uri: String,
        val sentence: String,
        val translation: String,
        val hint: String
)

data class RestItemToLearn(
        val uri: String,
        val label: String,
        val sentences: List<RestSentence>
)

data class RestLearningProgram(
        val uri: String,
        val originLanguageUri: String,
        val learnedLanguageUri: String,
        val itemsToLearn: List<RestItemToLearn>
)

val availableOriginLanguages: List<RestLanguage> = listOf(
        toRestLanguage(Language.French)
)

val availableLearnedLanguages: List<RestLanguage> = listOf(
        toRestLanguage(Language.Vietnamese)
)

fun toRestLanguage(language: Language): RestLanguage = RestLanguage(language.uri, language.label)

// variable to suppress on this deprecate
@Suppress("DEPRECATION")
private const val jsonUtf8Header: String = MediaType.APPLICATION_JSON_UTF8_VALUE

@RestController
class RestApi {

    @GetMapping("/api/v0/available_origin_languages", produces = [jsonUtf8Header])
    suspend fun getAvailableOriginLanguages(
            @RequestParam(value = "learned_language_uri") learnedLanguageUri: String): List<RestLanguage> {
        return availableOriginLanguages
    }

    @GetMapping("/api/v0/available_learned_languages", produces = [jsonUtf8Header])
    suspend fun getAvailableLearnedLanguages(): List<RestLanguage> {
        return availableLearnedLanguages
    }

    // dart client use latin1 format if utf-8 not explicitly specified by the server
    // https://github.com/dart-lang/http/issues/175
    @GetMapping("/api/v0/program", produces = [jsonUtf8Header])
    suspend fun getProgram(
            @RequestParam(value = "learned_language_uri") learnedLanguageUri: String,
            @RequestParam(value = "origin_language_uri") originLanguageUri: String): RestLearningProgram {

        val originLanguage = Language.fromUri(originLanguageUri)
        val learnedLanguage = Language.fromUri(learnedLanguageUri)

        val program = loadProgram(originLanguage, learnedLanguage)

        val programUri = generateUri("${learnedLanguageUri}-from-${originLanguageUri}-1")

        return RestLearningProgram(
                programUri,
                originLanguageUri,
                learnedLanguageUri,
                program.items.map {
                    val itemUri = generateUri(it.itemString, programUri)
                    RestItemToLearn(
                            itemUri,
                            it.itemString,
                            it.sentences
                                    .map { s -> RestSentence(generateUri(s.sentence, itemUri), s.sentence, s.translation, s.hint) }
                    ) }
        )
    }
}
