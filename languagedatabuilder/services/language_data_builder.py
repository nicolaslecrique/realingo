from dataclasses import dataclass
from typing import List
import json
from dataclasses_json import dataclass_json

from languages_toolboxes.api_language_toolbox import ExtractedSentences, Language, ExtractedSentence
from services.sentence_evaluator import SentenceEvaluator, Sentence, SentenceEvaluationResult


@dataclass_json
@dataclass(frozen=True)
class WordInSentenceInData:
    word_standard_format: str
    word_raw_format: str
    min_index_in_sentence: str
    max_index_in_sentence: str
    word_probability_in_sentence: float


@dataclass_json
@dataclass(frozen=True)
class SentenceData:
    raw_sentence: str
    words_in_sentence: List[WordInSentenceInData]
    sentence_probability: float


@dataclass_json
@dataclass(frozen=True)
class LanguageData:
    sentences: List[SentenceData]


class ExtractedSentencesBatchIterator:

    def __init__(self, file_path: str, batch_size):
        with open(file_path) as extracted_sentences_file:
            sentences_str: str = json.load(extracted_sentences_file)
            extracted_sentences_set: ExtractedSentences = ExtractedSentences.from_dict(sentences_str)
            self.extracted_sentences: List[ExtractedSentence] = extracted_sentences_set.sentences

        self.current_start_index = 0
        self.batch_size = batch_size

    def __iter__(self):
        return self

    def __next__(self) -> List[ExtractedSentence]:
        if self.current_start_index >= len(self.extracted_sentences):
            raise StopIteration
        end_batch_index = self.current_start_index + self.batch_size
        next_batch: List[ExtractedSentence] = self.extracted_sentences[self.current_start_index:end_batch_index]
        self.current_start_index = end_batch_index
        return next_batch


def build_language_data_from_file(file_path_extracted_sentences: str, language: Language) -> LanguageData:

    result_sentences: [SentenceData] = []
    batch_size: int = 10
    sentence_batch_it: ExtractedSentencesBatchIterator = ExtractedSentencesBatchIterator(file_path_extracted_sentences, batch_size)
    sentence_evaluator: SentenceEvaluator = SentenceEvaluator()

    batch: List[ExtractedSentence]
    for idx_batch, batch in enumerate(sentence_batch_it):

        print("processing batch " + str(idx_batch))

        try:
            sentences: List[Sentence] = [Sentence(
                sentence=extracted.full_sentence,
                words = [word.word_raw_format for word in extracted.learnable_words_in_sentence]
            ) for extracted in batch]

            eval_results: List[SentenceEvaluationResult] = sentence_evaluator.compute_sentences_and_word_proba(
                sentences, language)

            sentences_data = [_build_sentence_data(eval_result, extracted_sentence)
                              for eval_result, extracted_sentence in zip(eval_results, batch)]
            result_sentences.extend(sentences_data)

        except Exception as e:
            print("error " + str(e))
            print("batch: " + str(idx_batch))

    return LanguageData(sentences=result_sentences)



def _build_sentence_data(eval_result: SentenceEvaluationResult, sentence: ExtractedSentence):
    words_in_sentence: [WordInSentenceInData] = [WordInSentenceInData(
        word_standard_format=word.word_standard_format,
        word_raw_format=word.word_raw_format,
        min_index_in_sentence=word.min_index_in_sentence,
        max_index_in_sentence=word.max_index_in_sentence,
        word_probability_in_sentence=eval_result.words_proba[idx]
    ) for idx, word in enumerate(sentence.learnable_words_in_sentence)]

    sentence_data: SentenceData = SentenceData(
        raw_sentence=sentence.full_sentence,
        words_in_sentence=words_in_sentence,
        sentence_probability=eval_result.sentence_proba
    )
    return sentence_data
