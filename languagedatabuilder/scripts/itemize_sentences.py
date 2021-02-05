import json
from typing import List, Set

from services.sentence_itemize.dict_loader import load_dict, load_items_from_dict
from services.sentence_itemize.sentence_itemize import itemize_sentence, ItemizedSentence, ItemizedSentences

vn_dict = load_dict("../programs_data/vietnamese/vi_from_english_dict.json")
items: Set[str] = load_items_from_dict(vn_dict)

with open(f"../programs_data/vietnamese/open_subtitles.txt", "r") as open_subtitles_file:
    print("start read file")
    lines: List[str] = open_subtitles_file.read().splitlines()
    print("start itemize")
    itemized_sentences: ItemizedSentences = itemize_sentence(lines, items)
    print("start to_dict")
    serialized = itemized_sentences.to_dict()

    print("start dump")
    with open("../temp/itemized_sentences_vn.json", 'w') as dump_file_itemized:
        json.dump(serialized, dump_file_itemized)
    print("end dump")
