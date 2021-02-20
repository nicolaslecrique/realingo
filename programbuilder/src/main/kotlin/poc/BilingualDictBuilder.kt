import dataLoaders.DictEntry
import dataLoaders.DictLoader
import dataLoaders.WordSenseTranslation



private data class DictEntryKey(
    val word: String,
    val type: String?,
    val definition: String?
)

class BilingualDictBuilder {

    companion object {

        fun loadEnglish(sourceLanguageCode: String): Map<WordSenseTranslation, List<DictEntry>>{
            return DictLoader
                .load(sourceLanguageCode)
                .entries
                .flatMap { it.translations.map { t -> t to it } }
                .groupBy { it.first }
                .mapValues { it.value.map { p -> p.second } }
        }

        fun load(sourceLanguageCode: String, destinationLanguageCode: String):
                Map<WordSenseTranslation, List<DictEntry>> {

            val sourceDict = DictLoader
                .load(sourceLanguageCode)
                .entries
                .map { DictEntryKey(
                    it.definition.word,
                    it.definition.type,
                    it.definition.definition) to it.translations }
                .toMap()

            val destDict = DictLoader
                .load(destinationLanguageCode)
                .entries
                .map { DictEntryKey(
                    it.definition.word,
                    it.definition.type,
                    it.definition.definition) to it }
                .toMap()

            val allSourceTranslations = sourceDict
                .flatMap { pair ->
                    pair.value.map { pair.key to it }
                }
            val filteredSourceTranslationsAvailableInDest = allSourceTranslations
                .filter { destDict.containsKey(it.first) }

            val destToEntries = filteredSourceTranslationsAvailableInDest
                .map { it.second to destDict.getValue(it.first) }
                .groupBy { it.first }
                .mapValues { it.value.map { p -> p.second } }

            // TODO NICO DELETE: code for diagnose issues

            val any = destToEntries.any { it.key.word == "tớ" }
            val anySource = sourceDict.any {
                it.value.any { it.word == "tớ" }
            }
            val aunt = destDict.filter { it.key.word == "I" }.toList()

            val sourceListOk = allSourceTranslations.firstOrNull { it.second.word == "tớ" }
            val sourceListOkFilter = filteredSourceTranslationsAvailableInDest.firstOrNull { it.second.word == "tớ" }


            val nbVnInFr = sourceDict.count { destDict.containsKey(it.key)}
            println("nbVn in Fr: $nbVnInFr on total + ${sourceDict.size}")

            var noMatch = 0
            var closeMatch = 0
            for (entry in sourceDict){
                if (!destDict.containsKey(entry.key)){
                    if(entry.value.isNotEmpty()){
                        println("missing key: ${entry.key}")
                        val matchWordAndType =
                            destDict.filterKeys { it.word == entry.key.word && it.type == entry.key.type }
                        if (matchWordAndType.isEmpty()) {
                            noMatch++
                            println("----no close match")
                        } else {
                            closeMatch++
                            println("-----close matches : ${matchWordAndType.keys}")
                        }
                    }
                }
            }



            return destToEntries

        }
    }
}


// TODO NICO
// PB: en français:
// you {determiner} (the individual or group spoken/written to) :: [familiar] tu; [polite] vous
//you {determiner} (used before epithets for emphasis) :: [singular] espèce de, [plural] bande de
// en viet:
// you {determiner} ::
