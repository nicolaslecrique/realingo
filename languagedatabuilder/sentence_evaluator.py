from dataclasses import dataclass
from typing import List
import numpy as np
from transformers import AutoTokenizer, AutoModelForMaskedLM, XLMRobertaTokenizer, \
    XLMRobertaForMaskedLM
import torch
from languages_toolboxes.api_language_toolbox import Language


def _to_prefix(language: Language) -> str:
    if language == Language.VIETNAMESE:
        return "Tiếng Việt. "
    elif language == Language.FRENCH:
        return "Français. "
    raise ValueError("Unmanaged language: " + str(language))


@dataclass
class Sentence:
    sentence: str
    words: [str]
    # The tokenized sentence must contains the tokenized word, and then it is counted as "one" and masked together
    # Not all the tokens in the sentence are in "words" (punctuations, proper names, onomatopoeia...)


@dataclass
class SentenceEvaluationResult:
    sentence_proba: float
    words_proba: [np.ndarray]

@dataclass
class _SentenceEncoding:
    encoded_sentence: torch.tensor # 1D
    encoded_sentence_masked_by_word: torch.tensor # 2D
    idxes_of_masked_tokens_by_word: List[np.ndarray]


class SentenceEvaluator:

    def __init__(self):
        if torch.cuda.is_available():
            self.device = torch.device("cuda")
        else:
            self.device = torch.device("cpu")

        self.tokenizer: XLMRobertaTokenizer = AutoTokenizer.from_pretrained("xlm-roberta-large")
        self.model: XLMRobertaForMaskedLM = AutoModelForMaskedLM.from_pretrained("xlm-roberta-large").to(device=self.device)

    @staticmethod
    def _extract_mask_indexes_in_sentence(encoded_sentence: torch.tensor, encoded_words: [torch.tensor]) -> List[np.ndarray]:

        indexes = []
        size_encoded_sentence = encoded_sentence.shape[0]
        current_start_idx_in_sentence = 1 # after sos_token
        for encoded_word in encoded_words:
            size_encoded_word = encoded_word.shape[0]
            for idx_in_sentence in range(current_start_idx_in_sentence, size_encoded_sentence):
                end_index = idx_in_sentence + size_encoded_word
                if torch.equal(encoded_sentence[idx_in_sentence:end_index], encoded_word):
                    indexes.append(np.arange(idx_in_sentence, end_index, dtype=np.int))
                    current_start_idx_in_sentence = end_index
                    break
        if len(indexes) != len(encoded_words):
            raise Exception("problem with sentence")
        return indexes

    def _build_masked_sentences(self, encoded_sentence: torch.tensor, mask_indexes: List[np.ndarray]) -> torch.tensor:
        encoded_sentence_for_masks = encoded_sentence.repeat(len(mask_indexes), 1)
        for idx_mask_set, masks_idxes in enumerate(mask_indexes):
            encoded_sentence_for_masks[idx_mask_set, masks_idxes] = self.tokenizer.mask_token_id # fancy indexing
        return encoded_sentence_for_masks

    @staticmethod
    def _extract_log_proba_world_tensor_from_model_result(
            model_result_log_probs_by_word: torch.tensor, # Tensor(nb_words, nb_tokens_in_sentence, nb_tokens_in_dict)
            mask_indexes: List[np.ndarray],
            sentence_tokens: torch.tensor) -> np.ndarray:

        log_proba_mask_set = np.empty(len(mask_indexes))
        for mask_set_idx, masks_indexes in enumerate(mask_indexes):

            mask_set_log_prob = 0.0
            expected_tokens = sentence_tokens[masks_indexes]
            nb_token = masks_indexes.size
            for mask_index, target_token in zip(masks_indexes, expected_tokens):
                try:
                    mask_set_log_prob += model_result_log_probs_by_word[mask_set_idx, mask_index, target_token]
                except Exception as e:
                    print(e)
            mask_set_log_prob /= nb_token

            log_proba_mask_set[mask_set_idx] = mask_set_log_prob
        return log_proba_mask_set


    # return array of size nb_sentences, each row contains a numpy array of size nb_words_in_sentence with log_proba in each cell
    def evaluate_sentences_log_proba_by_word(self, sentences: List[Sentence], language: Language) -> List[np.ndarray]:

        with torch.no_grad():

            log_proba_by_word_by_sentence = []
            prefix: str = _to_prefix(language)

            sentence_encodings: [_SentenceEncoding] = [self._extract_encodings(sentence, prefix) for sentence in sentences]

            max_encoded_sentence_length = max(sentence_encoding.encoded_sentence.shape[-1] for sentence_encoding in sentence_encodings)
            all_sentence_tensors = [sentence_encoding.encoded_sentence_masked_by_word for sentence_encoding in sentence_encodings]
            padded_tensors = [torch.nn.functional.pad(tensor, (0, max_encoded_sentence_length-tensor.shape[-1]), value=self.tokenizer.pad_token_id) for tensor in all_sentence_tensors]

            encoded_sentences_concat = torch.cat(padded_tensors)
            model_result_all_sentences: torch.tensor = self.model(encoded_sentences_concat)[0]
            model_result_all_sentences_log_probs: torch.tensor = torch.nn.functional.log_softmax(model_result_all_sentences, dim=2)

            # get indexes splitting sentences in concat batch
            start_stop_indexes_in_concatenated_tensor: List[(int,int)] = []
            current_start_index = 0
            for sentence_encoding in sentence_encodings:
                size_sentence_encodings = sentence_encoding.encoded_sentence_masked_by_word.shape[0]
                end_index = current_start_index + size_sentence_encodings
                start_stop_indexes_in_concatenated_tensor.append((current_start_index, end_index))
                current_start_index = end_index

            model_result_by_sentence = [model_result_all_sentences_log_probs[start:stop, :, :] for start, stop in start_stop_indexes_in_concatenated_tensor]

            for sentence_encoding, model_result_log_probs in zip(sentence_encodings, model_result_by_sentence):

                log_proba_by_word: np.ndarray = self._extract_log_proba_world_tensor_from_model_result(
                    model_result_log_probs,
                    sentence_encoding.idxes_of_masked_tokens_by_word,
                    sentence_encoding.encoded_sentence)
                log_proba_by_word_by_sentence.append(log_proba_by_word)

            return log_proba_by_word_by_sentence

    def _extract_encodings(self, sentence: Sentence, prefix: str) -> _SentenceEncoding:

        prefixes_sentence = prefix + sentence.sentence
        encoded_words = [self.tokenizer.encode(word, add_special_tokens=False, return_tensors="pt")[0].to(device=self.device) for word in
                         sentence.words]

        encoded_sentence: torch.tensor = self.tokenizer.encode(prefixes_sentence, return_tensors="pt")[0].to(device=self.device)

        tokens_to_mask_idxs_in_sentence_by_words: List[np.ndarray] = self._extract_mask_indexes_in_sentence(
            encoded_sentence, encoded_words)

        encoded_sentence_for_masks: torch.tensor = self._build_masked_sentences(encoded_sentence,
                                                                                tokens_to_mask_idxs_in_sentence_by_words)
        return _SentenceEncoding(
            encoded_sentence=encoded_sentence,
            encoded_sentence_masked_by_word=encoded_sentence_for_masks,
            idxes_of_masked_tokens_by_word=tokens_to_mask_idxs_in_sentence_by_words)

    def compute_sentences_and_word_proba(self, sentences: List[Sentence], language: Language) -> List[SentenceEvaluationResult]:
        log_proba_arrays: List[np.ndarray] = self.evaluate_sentences_log_proba_by_word(sentences, language)
        return [SentenceEvaluationResult(
            sentence_proba=np.exp(np.mean(log_proba_array)),
            words_proba=np.exp(log_proba_array))
            for log_proba_array in log_proba_arrays]

    def print_words_proba(self, sentences: List[Sentence], language: Language):
        eval_results: [SentenceEvaluationResult] = self.compute_sentences_and_word_proba(sentences, language)
        for sentence, eval_result in zip(sentences, eval_results):
            print(sentence.sentence + ":" + str(eval_result.sentence_proba))
            for word, proba in zip(sentence.words, eval_result.words_proba):
                print(word + ":" + str(proba))

#
# s = SentenceEvaluator()
#
#
# sentences = [
#     Sentence(language=Language.VIETNAMESE, sentence="Đó là truyền thống gia đình.", words=["Đó", "là", "truyền thống", "gia đình"]),
#     Sentence(language=Language.VIETNAMESE, sentence="Đó là một truyền thống gia đình.", words=["Đó", "là", "một", "truyền thống", "gia đình"]),
#     Sentence(language=Language.VIETNAMESE, sentence="Đó là truyền thống.", words=["Đó", "là", "truyền thống"]),
#     Sentence(language=Language.VIETNAMESE, sentence="Hãy tôn trọng truyền thống.", words=["Hãy", "tôn trọng", "truyền thống"]),
# ]
#
#
sentences = [
    Sentence(sentence="Français. Il fait beau.", words=["Il", 'fait', 'beau']),
    Sentence(sentence="Français. Il fait beau aujourd'hui.", words=["Il", 'fait', 'beau', "aujourd'hui"]),
    Sentence(sentence="Français. Il fait un beau temps aujourd'hui.", words=["Il", 'fait', 'un', 'beau', 'temps', "aujourd'hui"]),
    Sentence(sentence="Français. Il est beau aujourd'hui.", words=["Il", 'est', 'beau', "aujourd'hui"]),
]
#

# sentences = [
#     Sentence(language=Language.FRENCH, sentence="Français. Il fait beau.", words=[])
#     ]
#
# for sentence in sentences:
#     s.print_words_proba(sentence)
#     print("===")

# s = SentenceEvaluator()
# s.print_words_proba(sentences)
