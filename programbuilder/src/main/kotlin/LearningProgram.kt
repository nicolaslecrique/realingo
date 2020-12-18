import kotlinx.serialization.Serializable

@Serializable
data class Sentence(
        val sentence: String,
        val translation: String,
        val hint: String
)

@Serializable
data class Item(
        val itemString: String,
        val sentences: List<Sentence>
)

@Serializable
data class LearningProgram(
        val items: List<Item>
)
