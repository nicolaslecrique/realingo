import kotlinx.serialization.Serializable

@Serializable
data class Sentence(
        val sentence: String,
        val translation: String
)

@Serializable
data class Item(
        val itemUri: String,
        val itemString: String,
        val sentences: List<Sentence>
)

@Serializable
data class LearningProgram(
        val items: List<Item>
)
