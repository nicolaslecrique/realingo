from dataclasses import dataclass
from typing import Dict, List
import json

from languages_toolboxes.api_language_toolbox import LearnableWordInSentence
from program_data_builder import LanguageProgramData, LearnableWordData, LearnableSentenceData, ExactSentenceData


@dataclass(frozen=True)
class SentenceInProgram:
    sentence: str
    words_in_sentence: [LearnableWordInSentence]


@dataclass(frozen=True)
class WordInProgram:
    word: str
    sentences_by_frequency: [SentenceInProgram]


@dataclass(frozen=True)
class LanguageProgram:
    words_by_frequency: [WordInProgram]


def dict_to_sorted_capped_list(dict: Dict, nb_elt: int) -> List:
    list_from_dict = list(dict.items())
    sorted_list = sorted(list_from_dict, key= lambda pair: -pair[1].count_in_corpus)
    sorted_list_capped = sorted_list[:nb_elt]
    return sorted_list_capped


def build_program(program_data: LanguageProgramData, nb_words: int, nb_sentences_by_word) -> LanguageProgram:

    sorted_word_list_capped = dict_to_sorted_capped_list(program_data.learnable_word_to_data, nb_words)

    words_by_frequency: [WordInProgram] = []

    word_data: LearnableWordData
    for word, word_data in sorted_word_list_capped:
        learnable_sentence_to_data: Dict[str, LearnableSentenceData] = word_data.learnable_sentence_to_data
        sorted_sentence_list_capped = dict_to_sorted_capped_list(learnable_sentence_to_data, nb_sentences_by_word)

        sentences_by_frequency: [SentenceInProgram] = []
        sentence_data: LearnableSentenceData
        for sentence, sentence_data in sorted_sentence_list_capped:
            exact_sentence_to_data: Dict[str, ExactSentenceData] = sentence_data.exact_sentence_to_data
            first_exact_sentence: ExactSentenceData = dict_to_sorted_capped_list(exact_sentence_to_data, 1)[0]

            sentences_by_frequency.append(SentenceInProgram(
                sentence=sentence,
                words_in_sentence=first_exact_sentence.learnable_words_in_sentence)
            )

        words_by_frequency.append(
            WordInProgram(
                word=word,
                sentences_by_frequency=sentences_by_frequency
            )
        )
    return LanguageProgram(words_by_frequency=words_by_frequency)

