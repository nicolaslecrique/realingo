from typing import Dict
from dataclasses import dataclass
import json

@dataclass(frozen=True)
class Word:
    word: str
    pos_tag: str


def build_frequency_list(tokenized_lines):
    i = 0
    word_to_count: Dict[Word, int] = {}

    for row in tokenized_lines:
        i += 1
        if i % 1000 == 0:
            print(i)
        for sentence in row["sentences"]:
            for word_dict in sentence:
                word: Word = Word(word=word_dict["form"], pos_tag=word_dict["posTag"])
                if word not in word_to_count:
                    word_to_count[word] = 0
                word_to_count[word] += 1

    word_to_count_list = [(vars(w), nb) for w,nb in word_to_count.items()]

    with open("temp/word_count_list_viet_dump.json", 'w') as dump_file:
        json.dump(word_to_count_list, dump_file)



with open("data/open_subtitles_vietnamese_annotated.json") as json_file:
    print("load json file")
    json_str = json_file.read()
    print("load json str into dict")
    open_subtitles_vientamese_annotated: Dict = json.loads(json_str)
    print("file loaded")
    build_frequency_list(open_subtitles_vientamese_annotated)

    print("done")
