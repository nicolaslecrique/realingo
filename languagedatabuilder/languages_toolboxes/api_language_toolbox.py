from enum import Enum
from typing import List
from dataclasses import dataclass
from dataclasses_json import dataclass_json

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

#exclude_pos_tags = {'Np', 'Ny', 'Nb', 'Vb', 'Y', 'Z', 'CH'}
# M: if it's nto digits  : don't add for now


#digit_pos_tag = 'M'
#proper_noun_pos_tags = 'Np'
#punctuation_symbols_pos_tags = 'CH'
#normal_words_pos_tags = {'Nc', 'Nu', 'N', 'V', 'A', 'P', 'R', 'L', 'E', 'C', 'Cc', 'I', 'T', 'X', 'Z'}
#exclude_sentence_pos_tags = {'Ny', 'Nb', 'Vb', 'Y'}

#not_excluded_sentence_punctuation_symbols_pos = {',', ';', '.', '!', '?'}


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

