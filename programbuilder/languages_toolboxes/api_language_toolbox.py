from typing import List, Dict, Tuple
from dataclasses import dataclass


@dataclass(frozen=True)
class FrequencyListWord:
    word: str
    count: int


@dataclass(frozen=True)
class LearnableWordsFrequencyList:
    sorted_words: List[FrequencyListWord]


@dataclass(frozen=True)
class ExtractedSentence:
    full_sentence: str
    full_sentence_traduction: str
    learnable_words_to_start_stop_index_in_sentence: Dict[str, Tuple[int, int]]  # under standard format


@dataclass(frozen=True)
class ExtractedSentences:
    sentences: List[ExtractedSentence]


class LanguageToolbox:

    def init(self, lines: List[str]):
        pass

    def extract_learnable_words(self) -> LearnableWordsFrequencyList:
        pass

    def extract_learnable_sentences(self) -> ExtractedSentences:
        pass

