from dataclasses import dataclass
from typing import List

import torch
from dataclasses_json import dataclass_json

from languages_toolboxes.api_language_toolbox import Language
from transformers import MarianMTModel, MarianTokenizer

@dataclass_json
@dataclass(frozen=True)
class TranslatedSentence:
    original_sentence: str
    translated_sentence: str
    back_translation: str
    confidence: float  # number between zero and one, for now: one if back-translation is equals to original sentence

# Helsinki-NLP/opus-mt-vi-fr
#  Helsinki-NLP/opus-mt-fr-vi [Has a model card]

def to_language_model_code(language: Language) -> str:
    if language == Language.VIETNAMESE:
        return 'vi'
    elif language == Language.FRENCH:
        return 'fr'
    else:
        raise ValueError(f"unknown language {language}")


def to_model_name(source_language: Language, target_language: Language) -> str:

    source: str = to_language_model_code(source_language)
    target: str = to_language_model_code(target_language)

    return f"Helsinki-NLP/opus-mt-{source}-{target}"


class Translator:

    back_model: MarianMTModel
    model: MarianMTModel
    back_tokenizer: MarianTokenizer
    tokenizer: MarianTokenizer

    def __init__(self, source_language: Language, target_language: Language):
        self.device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")

        model_name: str = to_model_name(source_language, target_language)
        back_model_name: str = to_model_name(target_language, source_language)
        
        self.tokenizer = MarianTokenizer.from_pretrained(model_name)
        self.back_tokenizer = MarianTokenizer.from_pretrained(back_model_name)

        self.model = MarianMTModel.from_pretrained(model_name).to(device=self.device)
        self.back_model = MarianMTModel.from_pretrained(back_model_name).to(device=self.device)

    def _translate(self, sentences: List[str], tokenizer: MarianTokenizer, model: MarianMTModel) -> [str]:
        tokenized = tokenizer.prepare_seq2seq_batch(sentences).to(device=self.device)
        translated_tokens = model.generate(**tokenized)
        translations: List[str] = [tokenizer.decode(t, skip_special_tokens=True) for t in translated_tokens]
        return  translations

    def translate(self, sentences: List[str]) -> List[TranslatedSentence]:

        with torch.no_grad():

            translations: List[str] = self._translate(sentences, self.tokenizer, self.model)
            back_translations: List[str] = self._translate(translations, self.back_tokenizer, self.back_model)

            translation_confidence: List[float] = [1.0 if o == bt else 0.0 for o, bt in zip(sentences, back_translations)]

            result = [TranslatedSentence(original_sentence=s, translated_sentence=t, back_translation=b, confidence=c)
                      for s, t, b, c in zip(sentences, translations, back_translations, translation_confidence)]

            return result


# TODO: to evaluate translation quality: compute sentence similarity
# with https://huggingface.co/sentence-transformers,
# https://huggingface.co/sentence-transformers/xlm-r-100langs-bert-base-nli-mean-tokens


# https://huggingface.co/pvl/labse_bert
# LaBSE is the SOTA pour sentence embeding for bitext mining, we can check the translation, or the back-translation ?



sentences_ex = [
    "Đó là truyền thống gia đình.",
    "Đó là một truyền thống gia đình.",
    "Đó là truyền thống.",
    "Hãy tôn trọng truyền thống."
]

# translator: Translator = Translator(Language.VIETNAMESE, Language.FRENCH)

# result: List[TranslatedSentence] = translator.translate(sentences_ex)

# for translated in result:
#     print(translated.translated_sentence + "-" + translated.back_translation + "-" + str(translated.confidence))
