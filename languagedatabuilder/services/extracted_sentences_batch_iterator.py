import json
from typing import List

from languages_toolboxes.api_language_toolbox import ExtractedSentences, ExtractedSentence


class ExtractedSentencesBatchIterator:

    def __init__(self, file_path: str, batch_size):
        with open(file_path) as extracted_sentences_file:
            sentences_str: str = json.load(extracted_sentences_file)
            extracted_sentences_set: ExtractedSentences = ExtractedSentences.from_dict(sentences_str)
            self.extracted_sentences: List[ExtractedSentence] = extracted_sentences_set.sentences

        self.current_start_index = 0
        self.batch_size = batch_size

    def __iter__(self):
        return self

    def __next__(self) -> List[ExtractedSentence]:
        if self.current_start_index >= len(self.extracted_sentences):
            raise StopIteration
        end_batch_index = self.current_start_index + self.batch_size
        next_batch: List[ExtractedSentence] = self.extracted_sentences[self.current_start_index:end_batch_index]
        self.current_start_index = end_batch_index
        return next_batch
