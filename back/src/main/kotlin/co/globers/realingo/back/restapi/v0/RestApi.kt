package co.globers.realingo.back.restapi.v0

import co.globers.realingo.back.model.ItemToLearn
import co.globers.realingo.back.model.LearningProgram
import co.globers.realingo.back.model.Sentence
import co.globers.realingo.back.model.Language
import co.globers.realingo.back.services.ProgramCache
import co.globers.realingo.back.services.ProgramKey
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

data class RestLanguage(
        val uri: String,
        val label: String
){
    constructor(language: Language): this(language.uri, language.label)
}

data class RestSentence(
        val uri: String,
        val sentence: String,
        val translation: String,
        val hint: String
) {
    constructor(sentence: Sentence) : this(sentence.uri, sentence.sentence, sentence.translation, sentence.hint)
}

data class RestItemToLearn(
        val uri: String,
        val label: String,
        val sentences: List<RestSentence>
) {
    constructor(item: ItemToLearn) : this(item.uri, item.label, item.sentences.map { RestSentence(it) })
}

data class RestLearningProgram(
        val uri: String,
        val originLanguageUri: String,
        val learnedLanguageUri: String,
        val itemsToLearn: List<RestItemToLearn>
){
    constructor(program: LearningProgram) :
        this(
            program.uri,
            program.originLanguageUri,
            program.learnedLanguageUri,
            program.itemsToLearn.map { RestItemToLearn(it) }
        )
}


// variable to suppress on this deprecate
@Suppress("DEPRECATION")
private const val jsonUtf8Header: String = MediaType.APPLICATION_JSON_UTF8_VALUE

@RestController
class RestApi(val programCache: ProgramCache) {

    @GetMapping("/api/v0/available_origin_languages", produces = [jsonUtf8Header])
    suspend fun getAvailableOriginLanguages(
            @RequestParam(value = "learned_language_uri") learnedLanguageUri: String): List<RestLanguage> {
        return programCache.availableOriginLanguages.map { RestLanguage(it) }
    }

    @GetMapping("/api/v0/available_learned_languages", produces = [jsonUtf8Header])
    suspend fun getAvailableLearnedLanguages(): List<RestLanguage> {
        return programCache.availableLearnedLanguages.map { RestLanguage(it) }
    }

    // dart client use latin1 format if utf-8 not explicitly specified by the server
    // https://github.com/dart-lang/http/issues/175
    @GetMapping("/api/v0/program", produces = [jsonUtf8Header])
    suspend fun getProgram(
            @RequestParam(value = "learned_language_uri") learnedLanguageUri: String,
            @RequestParam(value = "origin_language_uri") originLanguageUri: String): RestLearningProgram {

        val originLanguage = Language.fromUri(originLanguageUri)
        val learnedLanguage = Language.fromUri(learnedLanguageUri)

        val program = programCache.programs.getValue(ProgramKey(learnedLanguage, originLanguage))
        val restProgram = RestLearningProgram(program)

        return restProgram
    }


}
