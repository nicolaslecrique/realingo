from typing import List

from languages_toolboxes.api_language_toolbox import LanguageToolbox, ExtractedSentences, ExtractedSentence


class LinesBatchGenerator:

    def __init__(self, language_folder: str, nb_lines: int, batch_size: int):
        with open(f"programs_data/{language_folder}/open_subtitles.txt", "r") as open_subtitles_file:
            print("start read lines")
            lines: List[str] = open_subtitles_file.readlines()
            print("end read lines")
            self.lines = lines[:nb_lines]  # for dev

        self.current_start_index = 0
        self.batch_size = batch_size

    def __iter__(self):
        return self

    def __next__(self) -> List[str]:
        if self.current_start_index >= len(self.lines):
            raise StopIteration
        end_batch_index = self.current_start_index + self.batch_size
        next_batch: List[str] = self.lines[self.current_start_index:end_batch_index]
        self.current_start_index = end_batch_index
        return next_batch


def build_extracted_sentences(language_folder: str, language_toolbox: LanguageToolbox, nb_lines: int) -> ExtractedSentences:

    all_extracted_sentences: List[ExtractedSentence] = []
    batch_size: int = 10
    lines_batch_generator: LinesBatchGenerator = LinesBatchGenerator(language_folder=language_folder, nb_lines=nb_lines, batch_size=batch_size)
    for idx_batch, lines_batch in enumerate(lines_batch_generator):

        if idx_batch % 10 == 0:
            print("processing sentence " + str(idx_batch * batch_size))

        for line in lines_batch:
            extracted_sentences: List[ExtractedSentence] = language_toolbox.extract_learnable_sentences(line)
            all_extracted_sentences.extend(extracted_sentences)
    return ExtractedSentences(sentences=all_extracted_sentences)
