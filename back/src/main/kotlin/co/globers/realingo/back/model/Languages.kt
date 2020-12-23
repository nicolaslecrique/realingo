package co.globers.realingo.back.model

enum class Language(
        val shortCode: String,
        val uri: String,
        val label: String
) {
    Vietnamese("vn", "vietnamese", "Vietnamese"),
    French("fr", "french", "French");

    companion object {
        fun fromUri(uri: String): Language {
            return values().find { it.uri == uri }!!
        }
    }
}
