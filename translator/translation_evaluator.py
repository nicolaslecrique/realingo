from typing import List

from torch import Tensor
from transformers import AutoTokenizer, AutoModel
import torch


class TranslationEvaluator:

    def __init__(self):
        self.device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
        self.tokenizer = AutoTokenizer.from_pretrained("pvl/labse_bert", do_lower_case=False)
        self.model = AutoModel.from_pretrained("pvl/labse_bert").to(device=self.device)

    def evaluate_pair(self, left: List[str], right: List[str]) -> List[float]:
        encoded_left = self.tokenizer(left, padding=True, truncation=True, max_length=128, return_tensors='pt').to(device=self.device)
        encoded_right = self.tokenizer(right, padding=True, truncation=True, max_length=128, return_tensors='pt').to(device=self.device)

        with torch.no_grad():
            left_model_output = self.model(**encoded_left)
            left_embeddings = mean_pooling(left_model_output, encoded_left['attention_mask'])
            right_model_output = self.model(**encoded_right)
            right_embeddings = mean_pooling(right_model_output, encoded_right['attention_mask'])
            result: Tensor = torch.nn.functional.cosine_similarity(left_embeddings, right_embeddings, dim=1, eps=1e-8)
            result_list = result.detach().cpu().numpy().tolist()
            return result_list


# from sentence-transformers
def mean_pooling(model_output, attention_mask):
    token_embeddings = model_output[0] #First element of model_output contains all token embeddings
    input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
    sum_embeddings = torch.sum(token_embeddings * input_mask_expanded, 1)
    sum_mask = torch.clamp(input_mask_expanded.sum(1), min=1e-9)
    return sum_embeddings / sum_mask
