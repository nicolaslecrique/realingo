from enum import Enum
from typing import List, Generator
from dataclasses import dataclass


class Language(Enum):
    VIETNAMESE = 1,
    FRENCH = 2


@dataclass(frozen=True)
class LearnableWordInSentence:
    word_standard_format: str
    word_raw_format: str
    min_index_in_sentence: str
    max_index_in_sentence: str


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

    def extract_learnable_sentences(self) -> Generator[ExtractedSentence, None, None]:
        pass

