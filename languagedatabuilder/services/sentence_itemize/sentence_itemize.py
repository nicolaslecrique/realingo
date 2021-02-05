import string
from dataclasses import dataclass
from typing import List, Iterable
import ahocorasick
from dataclasses_json import dataclass_json


@dataclass_json
@dataclass(frozen=True)
class ItemInSentence:
    min_index: int
    max_index: int
    item_std_format: str


@dataclass_json
@dataclass(frozen=True)
class ItemizedSentence:
    sentence: str
    sentence_std_format: str
    items: List[ItemInSentence]


@dataclass_json
@dataclass(frozen=True)
class ItemizedSentences:
    sentences: List[ItemizedSentence]


def itemize_sentence(sentences: List[str], items: Iterable[str]) -> ItemizedSentences:

    ahoc_automaton = ahocorasick.Automaton()
    for item in items:
        ahoc_automaton.add_word(item, item)
    ahoc_automaton.make_automaton()
    result: List[ItemizedSentence] = []
    transtable = str.maketrans('', '', string.punctuation + string.whitespace)
    for sentence in sentences:
        sentence_std_format: str = sentence.lower()
        split_result = [res for res in ahoc_automaton.iter_long(sentence_std_format)]
        rebuilt_sentence = "".join(pair[1] for pair in split_result)
        rebuilt_compacted = rebuilt_sentence.translate(transtable)
        sentence_compacted = sentence_std_format.translate(transtable)
        if sentence_compacted == rebuilt_compacted:
            result.append(ItemizedSentence(
                sentence=sentence,
                sentence_std_format=sentence_std_format,
                items=[ItemInSentence(
                    item_std_format=pair[1],
                    min_index = pair[0] - len(pair[1]) + 1,
                    max_index=pair[0]
                ) for pair in split_result]
            ))
    return ItemizedSentences(sentences=result)
