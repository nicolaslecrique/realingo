from dataclasses import dataclass
from typing import List

import torch
from dataclasses_json import dataclass_json

from transformers import MarianMTModel, MarianTokenizer

from translation_evaluator import TranslationEvaluator


@dataclass_json
@dataclass(frozen=True)
class TranslatedSentence:
    original_sentence: str
    translated_sentence: str
    back_translation: str
    translation_score: float

# Helsinki-NLP/opus-mt-vi-en
#  Helsinki-NLP/opus-mt-en-vi [Has a model card]

def to_model_name(source_language: str, target_language: str) -> str:
    return f"Helsinki-NLP/opus-mt-{source_language}-{target_language}"


class Translator:

    back_model: MarianMTModel
    model: MarianMTModel
    back_tokenizer: MarianTokenizer
    tokenizer: MarianTokenizer

    def __init__(self, source_language: str, target_language: str):
        self.device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")

        model_name: str = to_model_name(source_language, target_language)
        back_model_name: str = to_model_name(target_language, source_language)
        
        self.tokenizer = MarianTokenizer.from_pretrained(model_name)
        self.back_tokenizer = MarianTokenizer.from_pretrained(back_model_name)

        self.model = MarianMTModel.from_pretrained(model_name).to(device=self.device)
        self.back_model = MarianMTModel.from_pretrained(back_model_name).to(device=self.device)
        self.evaluator = TranslationEvaluator()

    def _translate(self, sentences: List[str], tokenizer: MarianTokenizer, model: MarianMTModel) -> [str]:
        tokenized = tokenizer.prepare_seq2seq_batch(sentences, return_tensors="pt").to(device=self.device)
        translated_tokens = model.generate(**tokenized)
        translations: List[str] = [tokenizer.decode(t, skip_special_tokens=True) for t in translated_tokens]
        return translations

    def translate(self, sentences: List[str]) -> List[TranslatedSentence]:
        with torch.no_grad():

            translations: List[str] = self._translate(sentences, self.tokenizer, self.model)
            back_translations: List[str] = self._translate(translations, self.back_tokenizer, self.back_model)

            scores = self.evaluator.evaluate_pair(sentences, back_translations)

            result = [TranslatedSentence(original_sentence=s, translated_sentence=t, back_translation=b, translation_score=score)
                      for s, t, b, score in zip(sentences, translations, back_translations, scores)]

            return result

