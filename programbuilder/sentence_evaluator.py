from dataclasses import dataclass
from typing import List, Tuple
import numpy as np
from transformers import AutoTokenizer, AutoModelForMaskedLM, XLMRobertaTokenizer, \
    XLMRobertaForMaskedLM
import torch


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

class SentenceEvaluatorTwo:

    def __init__(self):
        self.tokenizer: XLMRobertaTokenizer = AutoTokenizer.from_pretrained("xlm-roberta-large")
        self.model: XLMRobertaForMaskedLM = AutoModelForMaskedLM.from_pretrained("xlm-roberta-large")

    @staticmethod
    def _extract_words_indexes_in_sentence(encoded_sentence: torch.tensor, encoded_words: [torch.tensor]) -> List[Tuple[int, int]]:

        indexes = []
        size_encoded_sentence = encoded_sentence.shape[0]
        current_start_idx_in_sentence = 0
        for encoded_word in encoded_words:
            size_encoded_word = encoded_word.shape[0]
            for idx_in_sentence in range(current_start_idx_in_sentence, size_encoded_sentence):
                end_index = idx_in_sentence + size_encoded_word
                if torch.equal(encoded_sentence[idx_in_sentence:end_index], encoded_word):
                    indexes.append((idx_in_sentence, end_index))
                    current_start_idx_in_sentence = end_index
                    break
        if len(indexes) != len(encoded_words):
            raise Exception("problem with sentence")
        return indexes

    def _build_masked_sentences(self, encoded_sentence: torch.tensor, mask_indexes: List[Tuple[int,int]]) -> torch.tensor:
        encoded_sentence_for_masks = encoded_sentence.repeat(len(mask_indexes), 1)
        for idx_word, (min_index, max_index) in enumerate(mask_indexes):
            encoded_sentence_for_masks[idx_word, min_index:max_index] = self.tokenizer.mask_token_id
        return encoded_sentence_for_masks

    @staticmethod
    def _extract_log_proba_world_tensor_from_model_result(
            model_result_log_probs_by_word: torch.tensor, # Tensor(nb_words, nb_tokens_in_sentence, nb_tokens_in_dict)
            min_max_mask_index_by_word: List[Tuple[int,int]],
            target_tokens_by_word: List[torch.tensor]) -> np.ndarray:

        log_proba_by_word = np.empty(len(min_max_mask_index_by_word))

        for word_idx, (min_max_mask_index_current_word, target_tokens_current_word) in enumerate(zip(min_max_mask_index_by_word, target_tokens_by_word)):

            word_log_prob = 0.0
            min_token_index = min_max_mask_index_current_word[0]
            max_token_index = min_max_mask_index_current_word[1]
            nb_token = max_token_index - min_token_index
            for mask_index, target_token in zip(range(min_token_index, max_token_index), target_tokens_current_word):
                word_log_prob += model_result_log_probs_by_word[word_idx, mask_index, target_token]
            word_log_prob /= nb_token

            log_proba_by_word[word_idx] = word_log_prob
        return log_proba_by_word


    # return array of size nb_sentences, each row contains a numpy array of size nb_words_in_sentence with log_proba in each cell
    def evaluate_sentence_log_proba_by_word(self, sentence: Sentence) -> np.ndarray:

        with torch.no_grad():

            #tokenized_sentence = self.tokenizer.tokenize(sentence.sentence)
            #tokenized_words = [self.tokenizer.tokenize(word) for word in sentence.words]

            encoded_words = [self.tokenizer.encode(word, add_special_tokens=False, return_tensors="pt")[0] for word in sentence.words]
            encoded_sentence: torch.tensor = self.tokenizer.encode(sentence.sentence, return_tensors="pt")[0]

            min_max_token_indexes_by_word: List[Tuple[int,int]] = self._extract_words_indexes_in_sentence(encoded_sentence, encoded_words)
            encoded_sentence_for_masks: torch.tensor = self._build_masked_sentences(encoded_sentence, min_max_token_indexes_by_word)
            model_result: torch.tensor = self.model(encoded_sentence_for_masks)[0]
            model_result_log_probs = torch.nn.functional.log_softmax(model_result, dim=2)
            log_proba_by_word: np.ndarray = self._extract_log_proba_world_tensor_from_model_result(model_result_log_probs, min_max_token_indexes_by_word, encoded_words)

            return log_proba_by_word



    def compute_sentence_and_word_proba(self, sentence: Sentence) -> SentenceEvaluationResult:
        log_proba_array = self.evaluate_sentence_log_proba_by_word(sentence)
        sentence_proba = np.exp(np.mean(log_proba_array))
        words_proba = np.exp(log_proba_array)
        return SentenceEvaluationResult(sentence_proba=sentence_proba, words_proba=words_proba)

    def print_words_proba(self, sentence: Sentence):
        eval_result: SentenceEvaluationResult = self.compute_sentence_and_word_proba(sentence)
        print(sentence.sentence + ":" + str(eval_result.sentence_proba))
        for word, proba in zip(sentence.words, eval_result.words_proba):
            print(word + ":" + str(proba))


s = SentenceEvaluatorTwo()


sentences = [
    Sentence(sentence="Le bébé a fait caca.", words=["Le", "bébé", "a", "fait", "caca"]),
    Sentence(sentence="Le bébé a fait caca dans sa couche.", words=["Le", "bébé", "a", "fait", "caca", 'dans', 'sa', 'couche']),
    Sentence(sentence="Le bébé fait caca dans sa couche.", words=["Le", "bébé", "fait", "caca", 'dans', 'sa', 'couche']),
    Sentence(sentence="Le bébé dans sa couche.", words=["Le", "bébé",'dans', 'sa', 'couche']),
    Sentence(sentence="Le bébé couche.", words=["Le", "bébé", 'couche']),
    Sentence(sentence="Le bébé se couche.", words=["Le", "bébé", 'se', 'couche']),
    Sentence(sentence="Le bébé se couches.", words=["Le", "bébé", 'se', 'couches']),
    Sentence(sentence="Bébé a fait dans sa couche.", words=["Bébé", "a", "fait", 'dans', 'sa', 'couche']),
    Sentence(sentence="Caca dans sa couche.", words=["caca", 'dans', 'sa', 'couche']),
    Sentence(sentence="Il est dans mon.", words=["il", 'est', 'dans', 'mon']),
]


sentences_ = [
    Sentence(sentence="Le bébé a fait caca.", words=["le", "bébé", "a", "fait", "caca"]),

]

#proba = s.compute_sentence_proba(sentences)
#print(proba)
for sentence in sentences:
    try:
        s.print_words_proba(sentence)
    except Exception as e:
        print(e)
    print("===")


#s.evaluate_word_in_sentence("Đó là một <mask> <mask> gia đình", "truyền thống")
#s.evaluate_word_in_sentence("This is really cool", "really")
