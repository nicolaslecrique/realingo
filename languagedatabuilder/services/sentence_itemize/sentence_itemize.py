import string
from dataclasses import dataclass
from typing import Set, List, Dict, Iterable

import numpy as np

from services.sentence_itemize.dict_loader import load_dict, WordSenseTranslation, DictionaryFromEnglish


def find_char_indexes_in_str(string: str, char: str):
    # 0.100 seconds for 1MB str
    np_buffer = np.frombuffer(string, dtype=np.uint8) # Reinterpret str as a char buffer
    return np.where(np_buffer == ord(char))          # Find indices with numpy


@dataclass
class PrefixTreeNode:
    is_item_end: bool # True if it's a word, no if it's only step toward
    children: Dict[str, 'PrefixTreeNode']


def build_prefix_tree(items: Iterable[str]) -> PrefixTreeNode:
    root: PrefixTreeNode = PrefixTreeNode(is_item_end=False, children={})
    for item in items:
        current_node: PrefixTreeNode = root
        split: List[str] = item.split()
        for token in split:
            if token not in current_node.children:
                current_node.children[token] = PrefixTreeNode(is_item_end=False, children={})
            current_node = current_node.children[token]
        current_node.is_item_end = True
    return root


def load_items_from_dict(dict: DictionaryFromEnglish) -> Set[str]:
    items: Set[str] = set()
    for entry in dict.entries:
        for trans in entry.translations:
            item: str = trans.word
            std_item = item.lower()
            items.add(std_item)
    return items


def get_possible_prefixes(sentence_normalized: str, itemsTree: PrefixTreeNode, split_indexes: List[int]) -> List[int]:

    result: List[int] = []
    current_start: int = 0
    current_node: PrefixTreeNode = itemsTree
    for idx in split_indexes:
        current_token = sentence_normalized[current_start:idx]
        if current_token in current_node.children:
            current_node = current_node.children[current_token]
            if current_node.is_item_end:
                result.append(idx)
            current_start = idx + 1
        else:
            # not possible other prefixes
            return result
    return result

# we suppose that sentence has not punctuation
def split_sentence_in_items(sentence_normalized: str, itemsTree: PrefixTreeNode, split_indexes: List[int]) -> List[str]:

    result: List[str] = []
    start_idx: int = 0
    current_list = []
    for idx in split_indexes:
        part: str = sentence_normalized[start_idx: idx]


    pass



vn_dict = load_dict("vi")
items: Set[str] = load_items_from_dict(vn_dict)
tree: PrefixTreeNode = build_prefix_tree(items)

with open(f"../../programs_data/vietnamese/open_subtitles.txt", "r") as open_subtitles_file:
    print("start read lines")
    lines: List[str] = open_subtitles_file.read().splitlines()
    transtable = str.maketrans(string.punctuation, '|'*len(string.punctuation))

    for line in lines:
        sentence = line.lower()
        without_punct = sentence.translate(transtable)
        whitespace_idxes = find_char_indexes_in_str(without_punct, ' ')
        sep_idxes = find_char_indexes_in_str(without_punct, '|')


        for sep_idx in sep_idxes:
            pass



        split: List[str] = sentence.split()
        current_str: List[str] = split
        while len(current_str) > 0:
            current_str_current_subset: List[str] = current_str
            while len(current_str_current_subset) > 0:
                str_to_find: str = string.join(current_str_current_subset)
                if str_to_find in items:
                    pass # TODO
                else:
                    # not found, we remove last item
                    current_str_current_subset = current_str_current_subset[:-1]

    print("end read lines")








print("vn dict loaded")


#IDEE:
# ON REMPLACE TOUtes les ponctuations par des "|"
# On cherche tous les indexes des " " et des "|"
# entre chaque '|' on va chercher les mots avec sentence[start:end] à chercher dans le dict
