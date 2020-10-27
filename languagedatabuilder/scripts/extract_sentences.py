import json

from services.extracted_sentences_builder import build_extracted_sentences
from languages_toolboxes.api_language_toolbox import ExtractedSentences
from languages_toolboxes.vietnamese_toolbox import VietnameseToolbox

with VietnameseToolbox() as viet_toolbox:
    sentences: ExtractedSentences = build_extracted_sentences("vietnamese", viet_toolbox, nb_lines=50)
    json_sentences = sentences.to_dict()

    print("start dump")
    with open("temp/extracted_sentences_vietnamese_50_ascii.json", 'w') as dump_file_tokenized:
        json.dump(json_sentences, dump_file_tokenized, indent=2, ensure_ascii=True)
    print("end dump")
