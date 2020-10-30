from typing import List, Tuple

from transformers import AutoTokenizer, AutoModel, BertModel, BertTokenizer
import torch

class SentenceSimilarityEvaluator:

    tokenizer: AutoTokenizer
    model: AutoModel

    def __init__(self):
        self.device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
        self.tokenizer: BertTokenizer = AutoTokenizer.from_pretrained("pvl/labse_bert", do_lower_case=False)
        self.model: BertModel = AutoModel.from_pretrained("pvl/labse_bert").to(device=self.device)

    # based on https://huggingface.co/pvl/labse_bert
    def mean_pooling(self, model_output, attention_mask):
        token_embeddings = model_output[0] #First element of model_output contains all token embeddings
        input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
        sum_embeddings = torch.sum(token_embeddings * input_mask_expanded, 1)
        sum_mask = torch.clamp(input_mask_expanded.sum(1), min=1e-9)
        return sum_embeddings / sum_mask

    def compute_sentence_embeddings(self, sentences: List[str]) -> torch.Tensor:
        with torch.no_grad():
            encoded = self.tokenizer(sentences, padding=True, return_tensors='pt').to(device=self.device)
            mode_output = self.model(**encoded)
            sentence_emb = self.mean_pooling(mode_output, encoded['attention_mask'])
            return sentence_emb

    def compute_similarity(self, sentences_pairs: List[Tuple[str, str]]) -> torch.Tensor:

        sentences_1: List[str] = [s1 for s1, _ in sentences_pairs]
        sentences_2: List[str] = [s2 for _, s2 in sentences_pairs]

        embeddings_1: torch.Tensor = self.compute_sentence_embeddings(sentences_1)
        embeddings_2: torch.Tensor = self.compute_sentence_embeddings(sentences_2)

        similarity: torch.Tensor = torch.nn.functional.cosine_similarity(embeddings_1, embeddings_2, dim=1)
        return similarity



sentence_pairs = [
    ("Il fait beau", "Il fait pas beau"),
    ("Il fait beau", "Il faut beau temps"),
    ("Il fait beau", "Il fait beau aujourd'hui."),
    ("Il fait beau", "Il fait un beau temps aujourd'hui."),
    ("Il fait beau", "Il est beau aujourd'hui."),
]

ev = SentenceSimilarityEvaluator()
result = ev.compute_similarity(sentence_pairs)
print(str(result))
