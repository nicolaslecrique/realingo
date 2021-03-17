package co.globers.realingo.back.dataloader

import co.globers.realingo.back.model.Language
import co.globers.realingo.back.tools.FileLoader
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

fun loadProgramFromFile(originLanguage: Language, learnedLanguage: Language): ProgramBuilderLearningProgram {
    val filename = "program_${learnedLanguage.shortCode}_from_${originLanguage.shortCode}.json"
    val programStr = FileLoader.getFileFromResource("programs/${filename}").readText()
    val program = Json.decodeFromString<ProgramBuilderLearningProgram>(programStr)
    return program
}
