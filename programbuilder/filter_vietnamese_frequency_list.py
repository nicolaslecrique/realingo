from typing import Dict, List
from dataclasses import dataclass
import json

@dataclass(frozen=True)
class Word:
    word: str
    pos_tag: str


# keep / merge / trash
# Label 	Meaning
# Np 	Proper noun
# Nc 	Classifier noun
# Nu 	Unit noun
# N 	Noun
# Ny 	Abbreviated noun
# Nb 	(Foreign) borrowed noun
# V 	Verb
# Vb 	(Foreign) borrowed verb
# A 	Adjective
# P 	Pronoun
# R 	Adverb
# L 	Determiner
# M 	Numeral/Quantity
# E 	Preposition
# C 	Subordinating conjunction
# Cc 	Coordinating conjunction
# I 	Interjection/Exclamation
# T 	Particle/Auxiliary, modal words
# Y 	Abbreviation
# Z 	Bound morpheme
# X 	Un-definition/Other
# CH 	Punctuation and symbols

exclude_pos_tags = {'Np', 'Ny', 'Nb', 'Vb', 'Y', 'Z', 'CH'}

include_pos_tags = {'Nc', 'Nu', 'N', 'V', 'A', 'P', 'R', 'L', 'E', 'C', 'Cc', 'I', 'T', 'X'}

# M: if it's nto digits  : don't add for now
digit_pos_tag = 'M'

with open("data/open_subtitles_vietnamese_freqlist_raw.json") as json_file:
    json_str = json_file.read()
    freqlist_raw_json: List = json.loads(json_str)

    freqlist_raw = {Word(word=entry[0]["word"],pos_tag=entry[0]["pos_tag"]): entry[1] for entry in freqlist_raw_json if entry[1]}

    filtered_freq_dict: Dict[str,Dict[str,int]] = {}

    # rely on word kinds only for filtering, then we merge on upper case and word type
    for word, count in freqlist_raw.items():
        if word.pos_tag in include_pos_tags:
            word_lower = word.word.lower()
            if word_lower not in filtered_freq_dict:
                count_by_tag = {tag: 0 for tag in include_pos_tags}
                count_by_tag['all'] = 0
                filtered_freq_dict[word_lower] = count_by_tag
            filtered_freq_dict[word_lower][word.pos_tag] += count
            filtered_freq_dict[word_lower]['all'] += count


    filtered_freq_list = list(filtered_freq_dict.items())
    sorted_filtered_freq_list = sorted(filtered_freq_list, key= lambda pair: -pair[1]['all'])
    trimmed_freq_list = sorted_filtered_freq_list[:10000]

    with open("temp/open_subtitles_vietnamese_freqlist_filtered.json", 'w') as freq_list_json:
        json.dump(trimmed_freq_list, freq_list_json)

    formated_list = [f"{entry[0]};{entry[1]['all']}\n" for entry in trimmed_freq_list]

    with open("temp/open_subtitles_vietnamese_freqlist_formated.txt", 'w') as freq_list_formatted:
        freq_list_formatted.writelines(formated_list)
