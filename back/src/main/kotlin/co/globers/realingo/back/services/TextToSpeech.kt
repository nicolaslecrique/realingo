package co.globers.realingo.back.services

import co.globers.realingo.back.model.Language
import com.google.cloud.texttospeech.v1.AudioConfig
import com.google.cloud.texttospeech.v1.AudioEncoding
import com.google.cloud.texttospeech.v1.SynthesisInput
import com.google.cloud.texttospeech.v1.TextToSpeechClient
import com.google.cloud.texttospeech.v1.VoiceSelectionParams
import org.springframework.stereotype.Service


enum class TtsLanguage(val languageCode: String, val voiceNames: List<String>){
    Vietnamese("vi-VN", listOf("vi-VN-Wavenet-A", "vi-VN-Wavenet-B", "vi-VN-Wavenet-C", "vi-VN-Wavenet-D"));

    companion object {
        fun fromLanguage(language: Language): TtsLanguage {
            return when(language){
                Language.Vietnamese -> Vietnamese
                else -> throw Exception("Language $language not managed by TextToSpeech")
            }
        }
    }
}


@Service
class TextToSpeech {



    // https://cloud.google.com/text-to-speech/docs/libraries#client-libraries-install-java
    fun getRecord(language: Language, sentence: String): ByteArray {

        val ttsLanguage = TtsLanguage.fromLanguage(language)

        TextToSpeechClient.create().use { textToSpeechClient ->
            // Set the text input to be synthesized
            val input =
                SynthesisInput.newBuilder().setText(sentence).build()

            val voice = VoiceSelectionParams.newBuilder()
                    .setLanguageCode(ttsLanguage.languageCode)
                    .setName(ttsLanguage.voiceNames.random())
                    .build()

            val audioConfig = AudioConfig.newBuilder().setAudioEncoding(AudioEncoding.LINEAR16).build()

            // Perform the text-to-speech request on the text input with the selected voice parameters and
            // audio file type
            val response =
                textToSpeechClient.synthesizeSpeech(input, voice, audioConfig)

            // Get the audio contents from the response
            val audioContents = response.audioContent

/*

FileOutputStream("output.wav").use { out ->
    out.write(audioContents.toByteArray())
    println("Audio content written to file \"output.wav\"")
}
*/

            return audioContents.toByteArray()
        }

    }
}


