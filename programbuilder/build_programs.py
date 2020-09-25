from dataclasses import dataclass
from typing import Dict

from languages_toolboxes.vietnamese_toolbox import VietnameseToolbox
from program_data_builder import build_program_data, LanguageProgramData, LearnableWordData, LearnableSentenceData, \
    ExactSentenceData


@dataclass(frozen=True)
class LanguageProgram:
    pass


program_data: LanguageProgramData = build_program_data("vietnamese", VietnameseToolbox())

word_index = 0
max_word_index = 2000

list_words = list(program_data.learnable_word_to_data.items())
sorted_word_list = sorted(list_words, key= lambda pair: -pair[1].count_in_corpus)
word_data: LearnableWordData
for word, word_data in sorted_word_list:
    print("=============")
    print("=============")
    print("=============")
    print(word + ": " + str(word_data.count_in_corpus))
    print("=============")
    print("=============")
    print("=============")

    sentence_index = 0
    max_sentence_index = 20
    word_index+=1
    if word_index == max_word_index:
        break

    learnable_sentence_to_data: Dict[str, LearnableSentenceData] = word_data.learnable_sentence_to_data
    sentence_list = list(learnable_sentence_to_data.items())
    sorted_sentence_list = sorted(sentence_list, key= lambda pair: -pair[1].count_in_corpus)
    sentence_data: LearnableSentenceData
    for sentence, sentence_data in sorted_sentence_list:

        print("====")
        print(sentence + ": " + str(sentence_data.count_in_corpus))
        print("====")
        sentence_index+=1
        if sentence_index == max_sentence_index:
            break


        exact_sentence_to_data: Dict[str, ExactSentenceData] = sentence_data.exact_sentence_to_data
        exact_sentence_list = list(exact_sentence_to_data.items())
        sorted_exact_sentence_list = sorted(exact_sentence_list, key= lambda pair: -pair[1].count_in_corpus)
        exact_sentence_data: ExactSentenceData

        max_exact=3
        exact_index = 0

        for exact_sentence, exact_sentence_data in sorted_exact_sentence_list:
            exact_index+=1
            if exact_index == max_exact:
                break
            print(exact_sentence + ": " + str(exact_sentence_data.count_in_corpus))



