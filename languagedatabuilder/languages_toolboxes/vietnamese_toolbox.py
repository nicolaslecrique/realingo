from dataclasses import dataclass

from languages_toolboxes.api_language_toolbox import LanguageToolbox, ExtractedSentences, \
    ExtractedSentence, LearnableWordInSentence
from typing import List, Dict, Tuple, Generator
from vncorenlp import VnCoreNLP


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


digit_pos_tag = 'M'
proper_noun_pos_tags = 'Np'
punctuation_symbols_pos_tags = 'CH'
normal_words_pos_tags = {'Nc', 'Nu', 'N', 'V', 'A', 'P', 'R', 'L', 'E', 'C', 'Cc', 'I', 'T', 'X', 'Z'}
exclude_sentence_pos_tags = {'Ny', 'Nb', 'Vb', 'Y'}

not_excluded_sentence_punctuation_symbols_pos = {',', ';', '.', '!', '?'}


def is_learnable_word(word: str, pos_tag: str):
    return pos_tag in normal_words_pos_tags or (pos_tag == digit_pos_tag and word.isalpha())


def is_exclude_word(word: str, pos_tag: str):
    return pos_tag in exclude_sentence_pos_tags or\
           (pos_tag == digit_pos_tag and not word.isalpha()) or \
           (pos_tag == punctuation_symbols_pos_tags and word not in not_excluded_sentence_punctuation_symbols_pos)



def fix_tone_bug_on_word(word: str) -> str:
    # always a space after the word, if it's last elt of of word or not
    suffixed = word + "_"
    suffixed_fixed = suffixed.replace("uý_", "úy_").replace("uỳ_", "ùy_").replace("uỷ_", "ủy_").replace("Uỷ_", "Ủy_") \
        .replace("oé_", "óe_").replace("oẻ_", "ỏe_") \
        .replace("oá_", "óa_").replace("oả_", "ỏa_").replace("oà_", "òa_").replace("oạ_", "ọa_").replace("oã_", "õa_") \
        .replace("qúy_", "quý_").replace("Qúy_", "Quý_").replace("qủy_", "quỷ_").replace("Qủy_", "Quỷ_")
    # quy: special case because "qu" is only one "letter"


    # remove last space
    return suffixed_fixed[:-1]


def fix_tone_bug_on_annotated_row(row):
    sentences = row["sentences"]
    for sentence in sentences:
        for word_dict in sentence:
            word: str = word_dict["form"]
            word_fixed = fix_tone_bug_on_word(word)
            word_dict["form"] = word_fixed



def to_standard_word(word: str):
    return fix_tone_bug_on_word(word).lower().replace("_", " ") # words annotated contains _ instead of " "


# associate to each words in each sentence the start/end index in "line". It is then trivial to split the line in words and sentences
def find_word_indexes_in_line(line: str, annotated_sentences: List) -> List[List[Tuple[int,int]]]:

    result = []
    current_index_in_line: int = 0

    for sentence in annotated_sentences:
        sentence_result = []
        result.append(sentence_result)
        for entry in sentence:
            form: str = entry["form"]
            # transform from to word
            word = form.replace("_"," ")
            start_index: int = line.find(word, current_index_in_line)
            if start_index < current_index_in_line:
                print("Issue with this line")
                print(word)
                print(line)
                return None
            else:
                end_index = start_index + len(word) - 1
                current_index_in_line = end_index
                sentence_result.append((start_index, end_index))
    return result


# Remains to see: Np,
# Np 	Proper noun => DONT_TRANSLATE

# Ny 	Abbreviated noun => EXCLUDE
# Nb 	(Foreign) borrowed noun => EXCLUDE
# Vb 	(Foreign) borrowed verb => EXCLUDE
# Y 	Abbreviation => EXCLUDE

# Z 	Bound morpheme : TRANSLATE,

# There is
# - Words excluding sentences
# - Words that don't matter (not translated)
# - Words to learn (can be translated)

@dataclass
class AnnotatedLine:
    line: str
    sentences: List[str]
    line_annotations: []  # object returned by vncorenlp.annotate(line)

    index_of_annotations_in_lines: List[List[Tuple[int,int]]]



class VietnameseToolbox(LanguageToolbox):

    lines = [str]

    def __init__(self, path_to_vn_core_nlp_jar="/Users/nicolas/dev/realingo/tools/VnCoreNLP/VnCoreNLP-1.1.1.jar"):
        self.path_to_vn_core_nlp_jar = path_to_vn_core_nlp_jar

    def init(self, lines: List[str]):
        self.lines = lines

    def extract_learnable_sentences(self) -> Generator[ExtractedSentence, None, None]:

        print("extract_learnable_sentences")

        with VnCoreNLP(
                self.path_to_vn_core_nlp_jar,
                annotators='wseg,pos',
                max_heap_size='-Xmx4g') as vncorenlp:

            for idx_line, row in enumerate(self.lines):

                if vncorenlp.detect_language(row) != 'vi':
                    continue

                tokenized_row= vncorenlp.annotate(row)
                fix_tone_bug_on_annotated_row(tokenized_row)

                tokenized_sentences = tokenized_row["sentences"]
                row_indexes: List[List[Tuple[int,int]]] = find_word_indexes_in_line(row, tokenized_sentences)
                if row_indexes is None:
                    print("exclude row")
                    continue

                for sentence_indexes, annotated_sentence in zip(row_indexes, tokenized_sentences):
                    sentence_start_index, _ = sentence_indexes[0]
                    _, sentence_last_index = sentence_indexes[-1]

                    full_sentence: str = row[sentence_start_index:sentence_last_index+1]
                    learnable_words_to_start_stop_index_in_sentence: Dict[str, Tuple[int, int]]

                    if any(is_exclude_word(annotated_word["form"], annotated_word["posTag"]) for annotated_word in annotated_sentence):
                        continue
                    else:

                        learnable_words_in_sentence = [
                            LearnableWordInSentence(
                                word_standard_format= to_standard_word(annotated_word["form"]),
                                word_raw_format= full_sentence[word_indexes[0]:word_indexes[1]+1],
                                min_index_in_sentence= word_indexes[0],
                                max_index_in_sentence= word_indexes[1]
                            )
                            for word_indexes, annotated_word in zip(sentence_indexes, annotated_sentence)
                            if is_learnable_word(annotated_word["form"], annotated_word["posTag"])
                        ]

                        if len(learnable_words_in_sentence) > 0:
                            extracted_sentence = ExtractedSentence(
                                full_sentence=full_sentence,
                                learnable_words_in_sentence=learnable_words_in_sentence
                            )

                            yield extracted_sentence

