

// TODO: REMOVE, we will do that in python to use ML if needed
/*
class SentenceItemMatcher {

    // sentence is a list of word
    // items are on or several words
    fun match(sentences: List<List<String>>, items: List<String>) : Map<String,List<String>> {

        val itemsSet = items.toSet()

        // TODO: check one-off issues
        for (sentence in sentences){
            var startIdx = 0
            while (startIdx < sentence.size){
                var endIdx = startIdx + 1
                var bestMatch: String? = null
                while (endIdx < sentence.size){
                    val stringToMatch = sentence.subList(startIdx, endIdx)
                }
            }


            val remainingString = sentence
            var bestMatch: String? = null
            while (remainingString.isNullOrBlank()){
                remainingString.subSequence()
            }
        }



        val itemsToSentences = items.map { it to mutableListOf<String>() }.toMap()
        for (item in items){
            for (sentence in sentences){
                if (sentence.contains(item)){
                    itemsToSentences[item]!!.add(sentence)
                }
            }
        }

        return emptyMap()
    }




}
*/
