import string
from dataclasses import dataclass
from typing import Set, List, Dict, Iterable, Tuple
import regex

import ahocorasick
import numpy as np

from services.sentence_itemize.dict_loader import load_dict, DictionaryFromEnglish


def find_char_indexes_in_str(string: str, char: str):
    # 0.100 seconds for 1MB str
    np_buffer = np.frombuffer(string, dtype=np.uint8) # Reinterpret str as a char buffer
    return np.where(np_buffer == ord(char))          # Find indices with numpy


def load_items_from_dict(dict: DictionaryFromEnglish) -> Set[str]:
    items: Set[str] = set()
    for entry in dict.entries:
        for trans in entry.translations:
            item: str = trans.word
            std_item: str = item.lower()
            if len(std_item) > 0:
                items.add(std_item)
    return items

vn_dict = load_dict("vi")
items: Set[str] = load_items_from_dict(vn_dict)
ahoc_automaton = ahocorasick.Automaton()
for item in items:
    ahoc_automaton.add_word(item, item)
ahoc_automaton.make_automaton()

# https://stackoverflow.com/questions/6314614/match-any-unicode-letter
# https://stackoverflow.com/questions/6314614/match-any-unicode-letter
# regex.UNICODE
pattern = regex.compile(r'\p{L}')


@dataclass(frozen=True)
class ItemizedSentence:
    sentence: str
    items: List[Tuple[int, int]]


with open(f"../../programs_data/vietnamese/open_subtitles.txt", "r") as open_subtitles_file:
    lines: List[str] = open_subtitles_file.read().splitlines()
    result = []
    errors = []
    transtable = str.maketrans('', '', string.punctuation + string.whitespace)
    for line in lines:
        sentence: str = line.lower()
        split_result = [res for res in ahoc_automaton.iter_long(sentence)]
        rebuilt_sentence = "".join(pair[1] for pair in split_result)
        rebuilt_compacted = rebuilt_sentence.translate(transtable)
        sentence_compacted = sentence.translate(transtable)
        if sentence_compacted == rebuilt_compacted:
            result.append(ItemizedSentence(
                sentence=line,
                items=[(pair[0] - len(pair[1]) + 1, pair[0]) for pair in split_result]
            ))
        else:
            errors.append(ItemizedSentence(
                sentence=line,
                items=[(pair[0] - len(pair[1]) + 1, pair[0]) for pair in split_result]
            ))








print("vn dict loaded")


#IDEE:
# ON REMPLACE TOUtes les ponctuations par des "|"
# On cherche tous les indexes des " " et des "|"
# entre chaque '|' on va chercher les mots avec sentence[start:end] à chercher dans le dict
