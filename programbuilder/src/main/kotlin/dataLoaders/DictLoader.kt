package dataLoaders

import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.File
import kotlin.system.measureNanoTime

@Serializable
data class WordSenseTranslation(
    val word: String,
    val genreNumber: String?, // {}
    val phonetic: String?, // /--/
    val context: String? // [---]
)
@Serializable
data class WordSenseEnglishDefinition(
    val word: String,
    val type: String?,
    val definition: String?,
    val phonetic: String?,
    val see: String?
)
@Serializable
data class DictEntry(
    val definition: WordSenseEnglishDefinition,
    val translations: List<WordSenseTranslation>
)

@Serializable
data class DictionaryFromEnglish(
    val entries: List<DictEntry>
)


// download instructions:
// https://en.wiktionary.org/wiki/User:Matthias_Buchmeier/download


class DictLoader {


    companion object {

        fun serialize(languageCode: String){
            val dictEntries = load(languageCode)
            val jsonString = Json.encodeToString(dictEntries)
            File("${languageCode}_from_english_dict.json").writeText(jsonString)
        }

        fun load(languageCode: String): DictionaryFromEnglish{

            val languageDataStr = FileLoader.getFileFromResource("./language_data/dict2/en-$languageCode-enwiktionary.txt")
                .readLines()

            // # is for comment, ]] is a bad line in the middle of the file
            val removedComments = languageDataStr
                .filter { ! it.startsWith("#") && ! it.startsWith("]]") }

            val words = removedComments.map { toDictEntry(it) }

            return DictionaryFromEnglish(words)
        }

        private fun toDictEntry(entryStr: String) : DictEntry {
            val splitDefAndTrans = entryStr.split("::")
            if (splitDefAndTrans.size != 2){
                throw Exception("oops")
            }
            val engDefStr = splitDefAndTrans[0]
            val transStr = splitDefAndTrans[1]
            val def = toDefinition(engDefStr)
            val transStrList = splitTranslations(transStr)
            val transList = transStrList.map { toTranslation(it) }
            return DictEntry(def, transList)
        }

        private fun toDefinition(engDefStr: String): WordSenseEnglishDefinition {

            val strInContexts = getEltsInScope(engDefStr, listOf(
                Pair('{', '}'),
                Pair('(', ')'),
                Pair('/', '/'),
            ))

            val type = strInContexts['{']
            val def = strInContexts['(']
            val phonetic = strInContexts['/']

            val splitSee = engDefStr.split("SEE:")
            val see = if (splitSee.size == 2){
                splitSee[1].trim()
            } else {
                null
            }
            val word = getMainString(engDefStr)
            return WordSenseEnglishDefinition(word, type, def, phonetic, see)
        }
        
        private fun getMainString(wholeString: String): String {
            val wholeStringTrimed = wholeString.trim()
            val startNotWordIndex = wholeStringTrimed.indexOfFirst { it in listOf('{', '(', '/', '[') }
            return if (startNotWordIndex == -1) {
                wholeStringTrimed
            } else if (startNotWordIndex == 0) {
                // if whole main is not at the beginning, we try to take it at the end
                val endNotWordIndex = wholeStringTrimed.indexOfLast { it in listOf('}', ')', '/', ']') }
                if (endNotWordIndex < wholeStringTrimed.length - 1) {
                    wholeStringTrimed.substring(endNotWordIndex + 1)
                } else {
                    // main string must be in the middle
                    val endOfBlockAtStart = wholeStringTrimed.indexOfFirst { it in listOf('}', ')', '/', ']') }
                    val startOfBlockAtEnd = wholeStringTrimed.indexOfLast { it in listOf('{', '(', '/', '[') }
                    if (endOfBlockAtStart < startOfBlockAtEnd) {
                        wholeStringTrimed.substring(endOfBlockAtStart + 1, startOfBlockAtEnd)
                    } else {
                        ""
                    }
                }
            } else {
                wholeStringTrimed.substring(0, startNotWordIndex)
            }.trim()
        }

        private fun toTranslation(translationStr: String): WordSenseTranslation {

            val strInContexts = getEltsInScope(translationStr, listOf(
                Pair('{', '}'),
                Pair('[', ']'),
                Pair('/', '/'),
                Pair('(', ')'),
            ))

            val genreNumber = strInContexts['{']
            val context = strInContexts['['] ?: strInContexts['(']
            val phonetic = strInContexts['/']

            // TODO NICO ICO: MAIN STRING CAN BE AFTER CONTEXT !!!
            // TODO: ";" est parfois un separateur entre les mots (rare)
            // TODO: parfois il y a des ensembles de mots plus grands que le tokenizer
            // et la traduction aurait plus de sens si on regroupait...à voir dans une V2...
            val translation = getMainString(translationStr)

            return WordSenseTranslation(translation, genreNumber, phonetic, context)
        }

        private fun splitTranslations(translationsStr: String): List<String>{

            if (translationsStr.isBlank()){
                return emptyList()
            }

            val listOfCommaIndexes = mutableListOf<Int>()
            var index: Int = translationsStr.indexOf(",")
            while (index >= 0) {
                listOfCommaIndexes.add(index)
                index = translationsStr.indexOf(",", index + 1)
            }

            val validCommas = listOfCommaIndexes.filter { commaIdx ->
                val substringBefore = translationsStr.substring(0, commaIdx)
                endStrOutsideScope(substringBefore, '(', ')') &&
                        endStrOutsideScope(substringBefore, '{', '}') &&
                        endStrOutsideScope(substringBefore, '[', ']')
            }

            var currentStateIndex = 0
            val translationSplit = mutableListOf<String>()
            for (commaIndex in validCommas){
                translationSplit.add(translationsStr.substring(currentStateIndex, commaIndex))
                currentStateIndex = commaIndex + 1
            }
            translationSplit.add(translationsStr.substring(currentStateIndex, translationsStr.length))
            return translationSplit
        }

        private fun endStrOutsideScope(str: String, startScope: Char, stopScope: Char): Boolean {
            val nbLeftParenthesis = str.count { it ==  startScope}
            val nbRightParenthesis = str.count { it ==  stopScope}
            return nbLeftParenthesis == nbRightParenthesis
        }

        private fun getEltsInScope(str: String, delimiters: List<Pair<Char,Char>>) : Map<Char,String> {
            var startIndexCurrentContext = 0
            var currentStartChar: Char? = null
            val result = mutableMapOf<Char,String>()

            val startChars = delimiters.map { it.first }
            val startToEndChars = delimiters.toMap()

            for ((index, char) in str.withIndex()) {
                if (currentStartChar == null && char in startChars){
                    startIndexCurrentContext = index
                    currentStartChar = char
                } else if (currentStartChar != null && char == startToEndChars[currentStartChar]){
                    result[currentStartChar] = str.substring(startIndexCurrentContext + 1, index)
                    currentStartChar = null
                    startIndexCurrentContext = index + 1
                }
            }
            return result
        }
    }

}

