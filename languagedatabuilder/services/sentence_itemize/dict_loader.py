from typing import Optional, List
from dataclasses import dataclass
from dataclasses_json import dataclass_json
import json

@dataclass_json
@dataclass(frozen=True)
class WordSenseTranslation:
    word: str
    phonetic: Optional[str]
    phonetic: Optional[str]
    context: Optional[str]

@dataclass_json
@dataclass(frozen=True)
class WordSenseEnglishDefinition:
    definition: Optional[str]
    phonetic: Optional[str]
    see: Optional[str]


@dataclass_json
@dataclass(frozen=True)
class DictEntry:
    definition: WordSenseEnglishDefinition
    translations: List[WordSenseTranslation]


@dataclass_json
@dataclass(frozen=True)
class DictionaryFromEnglish:
    entries: List[DictEntry]


def load_dict(language: str) -> DictionaryFromEnglish:

    with open(f"data/{language}_from_english_dict.json", "r") as dict_file:
        content: str = dict_file.read()
        dict: DictionaryFromEnglish = DictionaryFromEnglish.from_json(content)
        return dict

