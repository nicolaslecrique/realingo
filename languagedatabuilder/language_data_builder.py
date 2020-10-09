from dataclasses import dataclass
from typing import List

from dataclasses_json import dataclass_json

from languages_toolboxes.api_language_toolbox import LanguageToolbox, ExtractedSentences, LearnableWordInSentence, \
    Language
from sentence_evaluator import SentenceEvaluator, Sentence, SentenceEvaluationResult


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


def build_language_data(language_folder: str, language_toolbox: LanguageToolbox, nb_lines: int, language: Language) -> LanguageData:

    sentence_evaluator: SentenceEvaluator = SentenceEvaluator()

    result_sentences: [SentenceData] = []

    with open (f"programs_data/{language_folder}/open_subtitles.txt", "r") as open_subtitles_file:
        print("start read lines")
        lines: List[str] = open_subtitles_file.readlines()
        print("end read lines")
        lines = lines[:nb_lines]  # for dev
        language_toolbox.init(lines)

        extracted_sentences: ExtractedSentences = language_toolbox.extract_learnable_sentences()

        for sentence in extracted_sentences.sentences:
            learnable_words: [LearnableWordInSentence] = sentence.learnable_words_in_sentence

            words_array = [word.word_raw_format for word in learnable_words]
            sentence_for_evaluator = Sentence(language, sentence.full_sentence, words_array)
            eval_result: SentenceEvaluationResult = sentence_evaluator.compute_sentence_and_word_proba(sentence_for_evaluator)

            words_in_sentence: [WordInSentenceInData] = [WordInSentenceInData(
                word_standard_format= word.word_standard_format,
                word_raw_format= word.word_raw_format,
                min_index_in_sentence= word.min_index_in_sentence,
                max_index_in_sentence= word.max_index_in_sentence,
                word_probability_in_sentence= eval_result.words_proba[idx]
            ) for idx, word in enumerate(learnable_words)]

            sentence_data: SentenceData = SentenceData(
                raw_sentence= sentence.full_sentence,
                words_in_sentence= words_in_sentence,
                sentence_probability= eval_result.sentence_proba
            )

            result_sentences.append(sentence_data)

        return LanguageData(sentences=result_sentences)
