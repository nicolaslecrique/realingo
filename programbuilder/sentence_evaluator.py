from dataclasses import dataclass
from typing import List
import numpy as np
from transformers import AutoTokenizer, AutoModelForMaskedLM, XLMRobertaTokenizer, \
    XLMRobertaForMaskedLM
import torch

# TODO NICO: tester utiliser phobert car sinon c'est trop facile: quand 2 mots forment un seul mot
#le produit des 2 probas est proche de 1 alors que c'etait peut etre très dur de deviner ce mot

@dataclass
class Sentence:
    sentence: str
    words: [str]

@dataclass
class SentenceEvaluationResult:
    sentence_proba: float
    proba_by_word: [float]

class SentenceEvaluatorTwo:

    def __init__(self):
        self.tokenizer: XLMRobertaTokenizer = AutoTokenizer.from_pretrained("xlm-roberta-large")
        self.model: XLMRobertaForMaskedLM = AutoModelForMaskedLM.from_pretrained("xlm-roberta-large")

    # return tensor of (nb_word,nb_tokens) where each tokens of row i are masked
    def _build_encoded_sentence_masked_by_word(
            self, encoded_sentence: torch.tensor, encoded_words: [torch.tensor]) -> torch.tensor:

        encoded_sentence_for_masks = encoded_sentence.repeat(len(encoded_words), 1)
        current_start_index = 1
        for idx_word, encoded_word in enumerate(encoded_words):
            end_index = current_start_index + encoded_word.shape[1]
            encoded_sentence_for_masks[idx_word, current_start_index:end_index] = self.tokenizer.mask_token_id
            current_start_index = end_index

        return encoded_sentence_for_masks

    # return array of size nb_sentences, each row contains a numpy array of size nb_words_in_sentence with log_proba in each cell
    def evaluate_sentence_log_proba_by_word(self, sentences: [Sentence]) -> [np.ndarray]:

        with torch.no_grad():

            probas = []
            for sentence in sentences:
                encoded_words = [self.tokenizer.encode(word, add_special_tokens=False, return_tensors="pt") for word in sentence.words]
                encoded_sentence = self.tokenizer.encode(sentence.sentence, return_tensors="pt")

                nb_words = len(sentence.words)
                encoded_sentence_for_masks = self._build_encoded_sentence_masked_by_word(encoded_sentence, encoded_words)

                result_tensor = self.model(encoded_sentence_for_masks)[0]
                tensor_log_probs = torch.nn.functional.log_softmax(result_tensor, dim=2)

                current_start_index = 1
                log_proba_sentence = 1.0
                for idx_word, encoded_word in enumerate(encoded_words):
                    nb_tokens_this_word = encoded_word.shape[1]
                    log_proba_word = 0.0
                    encoded_word_1d_tensor = encoded_word[0,:]
                    for idx_token_in_word, expected_token_idx in enumerate(encoded_word_1d_tensor):
                        log_proba_word = log_proba_word + tensor_log_probs[idx_word, current_start_index + idx_token_in_word, expected_token_idx]
                    log_proba_word /= nb_tokens_this_word
                    log_proba_sentence += log_proba_word
                    current_start_index += nb_tokens_this_word
                log_proba_sentence /= nb_words
                probas.append(np.exp(log_proba_sentence.item()))
            return probas


sentences = [
    Sentence(sentence="Le bébé a fait caca", words=["Le", "bébé", "a", "fait", "caca"]),
    Sentence(sentence="Le bébé a fait caca dans sa couche", words=["Le", "bébé", "a", "fait", "caca", 'dans', 'sa', 'couche']),
    Sentence(sentence="Le bébé fait caca dans sa couche", words=["Le", "bébé", "fait", "caca", 'dans', 'sa', 'couche']),
    Sentence(sentence="Le bébé dans sa couche", words=["Le", "bébé",'dans', 'sa', 'couche']),
    Sentence(sentence="Le bébé couche", words=["Le", "bébé", 'couche']),
    Sentence(sentence="Bébé a fait dans sa couche", words=["bébé", "a", "fait", 'dans', 'sa', 'couche']),
    Sentence(sentence="Caca dans sa couche", words=["caca", 'dans', 'sa', 'couche']),
]
s = SentenceEvaluatorTwo()
proba = s.evaluate_sentence_log_proba_by_word(sentences)
print(proba)

#s.evaluate_word_in_sentence("Đó là một <mask> <mask> gia đình", "truyền thống")
#s.evaluate_word_in_sentence("This is really cool", "really")
