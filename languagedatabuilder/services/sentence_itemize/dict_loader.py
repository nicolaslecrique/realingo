from typing import Optional, List, Set
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


def load_dict(file_path: str) -> DictionaryFromEnglish:

    with open(file_path, "r") as dict_file:
        content: str = dict_file.read()
        dict: DictionaryFromEnglish = DictionaryFromEnglish.from_json(content)
        return dict


def load_items_from_dict(dict: DictionaryFromEnglish) -> Set[str]:
    items: Set[str] = set()
    for entry in dict.entries:
        for trans in entry.translations:
            item: str = trans.word
            std_item: str = item.lower()
            if len(std_item) > 0:
                items.add(std_item)
    return items
