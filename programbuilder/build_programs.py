from typing import List, Dict, Generator, TextIO
from dataclasses import dataclass
import json

from languages_toolboxes.api_language_toolbox import LanguageToolbox, LearnableWordsFrequencyList, ExtractedSentences
from languages_toolboxes.vietnamese_toolbox import VietnameseToolbox


@dataclass(frozen=True)
class LanguageProgram:
    pass

def build_program(language: str, language_toolbox: LanguageToolbox):

    with open (f"programs_data/{language}/open_subtitles.txt", "r") as open_subtitles_file:
        print("start read lines")
        lines: List[str] = open_subtitles_file.readlines()
        print("end read lines")
        lines = lines[:5000] # for dev
        language_toolbox.init(lines)

        frequency_list: LearnableWordsFrequencyList = language_toolbox.extract_learnable_words()

        sentences: ExtractedSentences = language_toolbox.extract_learnable_sentences()
        word_to_position = {freq_word.word: index for index,freq_word in enumerate(frequency_list.sorted_words)}

        word_to_sentences = {word.word: [] for word in frequency_list.sorted_words}

        for sentence in sentences.sentences:
            learnable_words = sentence.learnable_words_to_start_stop_index_in_sentence.keys()
            max_word_index = 0
            less_frequent_word_in_sentence: str = ""
            for word in learnable_words:
                current_word_index = word_to_position[word]
                if current_word_index > max_word_index:
                    less_frequent_word_in_sentence = word
                    max_word_index = current_word_index
            word_to_sentences[less_frequent_word_in_sentence].append(sentence)

        print(word_to_sentences)



build_program("vietnamese", VietnameseToolbox())

