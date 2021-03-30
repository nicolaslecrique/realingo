package dataLoaders

// file is from https://www.freewebheaders.com/youtube-blacklist-words-list-youtube-comment-moderation/

class BlacklistLoader {

    companion object {
        fun buildEnglishBlacklist(): Set<String> {

            val languageDataStr = FileLoader.getFileFromResource("./language_data/english-blacklist.txt")
                .readLines()

            val wordLine = languageDataStr.first { it.isNotBlank() && !it.startsWith("#") }
            val words = wordLine.split(',').map { it.trim() }
            return words.toSet()
        }
    }


}
