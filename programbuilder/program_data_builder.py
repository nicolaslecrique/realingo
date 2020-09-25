from dataclasses import dataclass
from typing import Dict, List

from languages_toolboxes.api_language_toolbox import LearnableWordInSentence, LanguageToolbox, \
    LearnableWordsFrequencyList, ExtractedSentences


@dataclass
class ExactSentenceData:
    count_in_corpus: int
    learnable_words_in_sentence: [LearnableWordInSentence]


@dataclass
class LearnableSentenceData:
    exact_sentence_to_data: Dict[str, ExactSentenceData]
    count_in_corpus: int


@dataclass
class LearnableWordData:
    # key is string representation of array of learnable words (order kept)
    # What is specific to the exact sentence is proper names, punctuations, case...
    learnable_sentence_to_data: Dict[str, LearnableSentenceData]
    count_in_corpus: int


@dataclass
class LanguageProgramData:
    learnable_word_to_data: Dict[str,LearnableWordData]


def build_program_data(language: str, language_toolbox: LanguageToolbox) -> LanguageProgramData:

    with open (f"programs_data/{language}/open_subtitles.txt", "r") as open_subtitles_file:
        print("start read lines")
        lines: List[str] = open_subtitles_file.readlines()
        print("end read lines")
        lines = lines[:5000]  # for dev
        language_toolbox.init(lines)

        frequency_list: LearnableWordsFrequencyList = language_toolbox.extract_learnable_words()

        extracted_sentences: ExtractedSentences = language_toolbox.extract_learnable_sentences()

        word_to_count = {freq_word.word: freq_word.count for freq_word in frequency_list.sorted_words}

        language_program_data: LanguageProgramData = LanguageProgramData(
            learnable_word_to_data={word.word: LearnableWordData(
                learnable_sentence_to_data={},
                count_in_corpus=word.count)
                for word in frequency_list.sorted_words}
        )

        for sentence in extracted_sentences.sentences:
            learnable_words: [LearnableWordInSentence] = sentence.learnable_words_in_sentence
            min_word_count = 1000000000
            less_frequent_word_in_sentence: str = ""
            for word_in_sentence in learnable_words:
                current_word_count = word_to_count[word_in_sentence.word]
                if current_word_count < min_word_count:
                    less_frequent_word_in_sentence = word_in_sentence.word
                    min_word_count = current_word_count

            learnable_sentence_to_data: Dict[str, LearnableSentenceData] =\
                language_program_data.learnable_word_to_data[less_frequent_word_in_sentence].learnable_sentence_to_data

            learnable_sentence_repr = repr([word_in_sentence.word for word_in_sentence in learnable_words])

            if learnable_sentence_repr not in learnable_sentence_to_data:
                learnable_sentence_to_data[learnable_sentence_repr] = LearnableSentenceData(
                    exact_sentence_to_data={},
                    count_in_corpus=1
                )
            else:
                learnable_sentence_to_data[learnable_sentence_repr].count_in_corpus += 1

            learnable_sentence_data: LearnableSentenceData = learnable_sentence_to_data[learnable_sentence_repr]

            exact_sentence_to_data: Dict[str, ExactSentenceData] = learnable_sentence_data.exact_sentence_to_data
            if sentence.full_sentence not in exact_sentence_to_data:
                exact_sentence_to_data[sentence.full_sentence] = ExactSentenceData(
                    count_in_corpus=1,
                    learnable_words_in_sentence= learnable_words
                )
            else:
                exact_sentence_to_data[sentence.full_sentence].count_in_corpus += 1

        return language_program_data
