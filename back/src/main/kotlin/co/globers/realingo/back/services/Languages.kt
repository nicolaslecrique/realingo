package co.globers.realingo.back.services

enum class Language(
        val shortCode: String,
        val languageUri: String,
        val languageLabel: String
) {
    Vietnamese("vn", "vietnamese", "Vietnamese"),
    English("en", "english", "English"),
    French("fr", "french", "French"),
    Spanish("sp","spanish", "Spanish");

    companion object {
        fun fromUri(uri: String): Language {
            return values().find { it.languageUri == uri }!!
        }
    }
}
