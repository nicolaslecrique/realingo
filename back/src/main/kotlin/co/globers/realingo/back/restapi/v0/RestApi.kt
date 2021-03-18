package co.globers.realingo.back.restapi.v0

import co.globers.realingo.back.model.Language
import co.globers.realingo.back.services.ProgramCache
import co.globers.realingo.back.services.ProgramKey
import co.globers.realingo.back.services.TextToSpeech
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController



// variable to suppress on this deprecate
@Suppress("DEPRECATION")
private const val jsonUtf8Header: String = MediaType.APPLICATION_JSON_UTF8_VALUE

@RestController
class RestApi(val programCache: ProgramCache, val textToSpeech: TextToSpeech) {

    @GetMapping("/api/v0/available_origin_languages", produces = [jsonUtf8Header])
    suspend fun getAvailableOriginLanguages(
            @RequestParam(value = "learned_language_uri") learnedLanguageUri: String): List<RestLanguage> {
        return programCache.availableOriginLanguages.map { ModelToRestAdapter.toRest(it) }
    }

    @GetMapping("/api/v0/available_learned_languages", produces = [jsonUtf8Header])
    suspend fun getAvailableLearnedLanguages(): List<RestLanguage> {
        return programCache.availableLearnedLanguages.map { ModelToRestAdapter.toRest(it) }
    }

    // dart client use latin1 format if utf-8 not explicitly specified by the server
    // https://github.com/dart-lang/http/issues/175
    @GetMapping("/api/v0/program_by_language", produces = [jsonUtf8Header])
    suspend fun getProgramByLanguage(
            @RequestParam(value = "learned_language_uri") learnedLanguageUri: String,
            @RequestParam(value = "origin_language_uri") originLanguageUri: String): RestLearningProgram {

        val originLanguage = Language.fromUri(originLanguageUri)
        val learnedLanguage = Language.fromUri(learnedLanguageUri)

        val programUri = programCache.availablePrograms.getValue(ProgramKey(learnedLanguage, originLanguage))
        val program = programCache.programsByUri.getValue(programUri)
        val restProgram = ModelToRestAdapter.toRest(program)
        return restProgram
    }

    @GetMapping("/api/v0/program", produces = [jsonUtf8Header])
    suspend fun getProgram(
        @RequestParam(value = "program_uri") programUri: String): RestLearningProgram {

        val program = programCache.programsByUri.getValue(programUri)
        val restProgram = ModelToRestAdapter.toRest(program)
        return restProgram
    }


    @GetMapping("/api/v0/lesson", produces = [jsonUtf8Header])
    suspend fun getLesson(
        @RequestParam(value = "program_uri") programUri: String,
        @RequestParam(value = "lesson_uri") lessonUri: String
    ): RestLesson {

        val program = programCache.programsByUri.getValue(programUri)
        val lesson = program.lessons.first { it.uri == lessonUri }
        val restLesson = ModelToRestAdapter.toRest(lesson)
        return restLesson
    }

    @GetMapping("/api/v0/sentence_record", produces = [MediaType.APPLICATION_OCTET_STREAM_VALUE])
    suspend fun getSentenceRecord(
        @RequestParam(value = "language_uri") languageUri: String,
        @RequestParam(value = "sentence") sentence: String) : ByteArray {

        val result = textToSpeech.getRecord(Language.fromUri(languageUri), sentence)
        return result
    }


}
