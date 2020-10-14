from enum import Enum
from typing import List, Generator
from dataclasses import dataclass

from dataclasses_json import dataclass_json


class Language(Enum):
    VIETNAMESE = 1,
    FRENCH = 2

@dataclass_json
@dataclass(frozen=True)
class LearnableWordInSentence:
    word_standard_format: str
    word_raw_format: str
    min_index_in_sentence: str
    max_index_in_sentence: str

@dataclass_json
@dataclass(frozen=True)
class ExtractedSentence:
    full_sentence: str
    learnable_words_in_sentence: List[LearnableWordInSentence]  # under standard format

@dataclass_json
@dataclass(frozen=True)
class ExtractedSentences:
    sentences: List[ExtractedSentence]


class LanguageToolbox:

    def extract_learnable_sentences(self, line: str) -> List[ExtractedSentence]:
        pass

