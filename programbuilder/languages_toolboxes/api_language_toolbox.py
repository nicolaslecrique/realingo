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
class LearnableWordInSentence:
    word: str
    start_index: int
    end_index: int


@dataclass(frozen=True)
class ExtractedSentence:
    full_sentence: str
    learnable_words_in_sentence: [LearnableWordInSentence]  # under standard format


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

