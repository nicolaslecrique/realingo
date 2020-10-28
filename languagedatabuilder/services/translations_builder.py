from dataclasses import dataclass
from typing import List

from dataclasses_json import dataclass_json

from languages_toolboxes.api_language_toolbox import Language, ExtractedSentence
from services.extracted_sentences_batch_iterator import ExtractedSentencesBatchIterator
from services.translator import TranslatedSentence, Translator

@dataclass_json
@dataclass(frozen=True)
class SentencesTranslation:
    translated_sentences: List[TranslatedSentence]


def translate_sentences(
        file_path_extracted_sentences: str,
        source_language: Language,
        target_language: Language) -> SentencesTranslation:

    result_sentences: List[TranslatedSentence] = []
    batch_size: int = 20
    sentence_batch_it: ExtractedSentencesBatchIterator = ExtractedSentencesBatchIterator(file_path_extracted_sentences, batch_size)

    translator: Translator = Translator(source_language, target_language)

    batch: List[ExtractedSentence]
    for idx_batch, batch in enumerate(sentence_batch_it):
        print(f"translate batch {idx_batch}")

        try:
            batch_str = [e.full_sentence for e in batch]
            translated_batch: List[TranslatedSentence] = translator.translate(batch_str)
            result_sentences.extend(translated_batch)

        except Exception as e:
            print("error " + str(e))
            print("batch: " + str(idx_batch))

    return SentencesTranslation(translated_sentences=result_sentences)
