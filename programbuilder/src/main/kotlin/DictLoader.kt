class WordTranslation(
    val word: String,
    val genre: String,
    val nombre: String,
    val phonetic: String,
)

class WordDef(
    val word: String,
    val type: String,
    val definition: String,
    val phonetic: String,
    val see: String
)

class DictEntry(
    val definition: WordDef,
    val translations: List<WordTranslation>
)

class DictLoader {


    companion object {
        fun load(languageCode: String): List<DictEntry>{

            val languageDataStr = FileLoader
                .getFileFromResource("./language_data/dict/en-$languageCode-enwiktionary.txt")
                .readLines()

            val removedComments = languageDataStr.filter { ! it.startsWith("#") }

            val words = removedComments.map { toDictEntry(it) }

            return words
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

        private fun toDefinition(engDefStr: String): WordDef {
            return WordDef(engDefStr, "", "", "", "")
        }

        private fun toTranslation(translationStr: String): WordTranslation {
            return WordTranslation(translationStr, "", "", "")
        }

        private fun splitTranslations(translationsStr: String): List<String>{

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



    }

}
