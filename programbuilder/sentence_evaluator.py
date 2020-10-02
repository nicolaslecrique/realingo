from typing import List
import numpy as np
from transformers import AutoTokenizer, AutoModelWithLMHead, AutoModelForMaskedLM, XLMRobertaTokenizer, \
    XLMRobertaForMaskedLM, pipeline

# TODO NICO: tester utiliser phobert car sinon c'est trop facile: quand 2 mots forment un seul mot
#le produit des 2 probas est proche de 1 alors que c'etait peut etre très dur de deviner ce mot

class Sentence:
    sentence: str
    words: [str]

class SentenceEvaluatorTwo:

    def __init__(self):
        self.tokenizer: XLMRobertaTokenizer = AutoTokenizer.from_pretrained("xlm-roberta-large")
        self.model: XLMRobertaForMaskedLM = AutoModelForMaskedLM.from_pretrained("xlm-roberta-large")

    def evaluate_sentence(self, sentences: [Sentence]) -> [float]:

        for sentence in sentences:
            encoded_sentence = self.tokenizer.encode(sentence.sentence)
            encoded_words = self.tokenizer.encode([word for word in sentence.words])







class VietnameseSentenceEvaluator:
    #self.tokenizer: XLMRobertaTokenizer = AutoTokenizer.from_pretrained("vinai/phobert-large")
    #self.model: XLMRobertaForMaskedLM = AutoModelForMaskedLM.from_pretrained("vinai/phobert-large")
    pass


# TODO: le code marche pas car les mots sont découpés avec xlm-roberta: par exemple: couche devient "_cou", "che",
# il faut gérer le cas ou le découpage se fait au milieu d'un mot

class SentenceEvaluator:

    def __init__(self):
        self.tokenizer: XLMRobertaTokenizer = AutoTokenizer.from_pretrained("xlm-roberta-large")
        self.model: XLMRobertaForMaskedLM = AutoModelForMaskedLM.from_pretrained("xlm-roberta-large")

        self.fill_mask_pipeline = pipeline("fill-mask", self.model, tokenizer=self.tokenizer)

    def evaluate_sentences_proba(self, sentences: [str]) -> List[float]:

        proba_by_sentences = []
        for sentence in sentences:
            tokenized_sentence: [str] = self.tokenizer.tokenize(sentence)
            tokenized_without_underscores: [str] = [token.replace("▁", "") for token in tokenized_sentence]
            sentence_with_masks: [str] = [sentence.replace(token, self.tokenizer.mask_token, 1) for token in tokenized_without_underscores]
            sum_log_proba = 1.0
            for masked_sentence, token in zip(sentence_with_masks, tokenized_without_underscores):
                this_token_result_by_sentence = self.fill_mask_pipeline(masked_sentence, targets=token)
                sum_log_proba += np.log(this_token_result_by_sentence[0]["score"])
            proba_by_sentences.append(np.exp(sum_log_proba/len(tokenized_sentence)))
        return proba_by_sentences

    def evaluate_sentences_for_word(self, sentences: [str], word_to_guess: str) -> [float]:

        tokenized_word_to_guess: List[str] = self.tokenizer.tokenize(word_to_guess)
        tokenized_without_underscores: List[str] = [token.replace("▁", "") for token in tokenized_word_to_guess]

        scores_all_tokens = np.ones(len(sentences))
        for token in tokenized_without_underscores:
            sentences_with_mask: [str] = [sentence.replace(token, self.tokenizer.mask_token, 1) for sentence in sentences]

            this_token_result_by_sentence = self.fill_mask_pipeline(sentences_with_mask, targets=token)

            scores = [sentence_result[0]["score"] for sentence_result in this_token_result_by_sentence]
            scores_all_tokens *= scores
        return scores_all_tokens.tolist()


# TODO gerer le fait que suivant la phase le mot n est pas exactement le meme meme si cest le meme learnable word


        # tokenized = self.tokenizer.tokenize(sentence)

        # Add start and end token, tokenize then convert to ids
        # tokenized_encoded = self.tokenizer.encode(sentence)

        #ids = self.tokenizer.convert_tokens_to_ids(tokenized)

        # result_mask_pipeline = self.fill_mask_pipeline(sentence)

        # print(tokenized)


s = SentenceEvaluator()

sentences_tradition = [
    "Đó là truyền thống gia đình",
    "Đó là một truyền thống gia đình",
    "Đó là truyền thống",
    "Hãy tôn trọng truyền thống",
    "Một trong những cuộc chiến quan trọng nhất là chống lại truyền thống"
]

#proba_word = s.evaluate_sentences_for_word(sentences_tradition, "truyền thống")
#print(proba_word)

#proba = s.evaluate_sentences_proba(sentences_tradition)
#print(proba)


sentences = [
    "Le bébé a fait caca dans sa couche",
    "Plus de couches pour le bébé",
    "Je te promet le ciel au dessus de ta couche",
    "Le bébé fait caca dans sa couche"
]

proba = s.evaluate_sentences_proba(sentences)
print(proba)

#s.evaluate_word_in_sentence("Đó là một <mask> <mask> gia đình", "truyền thống")
#s.evaluate_word_in_sentence("This is really cool", "really")
