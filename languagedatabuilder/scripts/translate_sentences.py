import json

from languages_toolboxes.api_language_toolbox import Language
from services.translations_builder import translate_sentences, SentencesTranslation

result: SentencesTranslation = translate_sentences("../temp/extracted_sentences_vietnamese_200.json", Language.VIETNAMESE, Language.FRENCH)

json_result = result.to_dict()

print("start dump")
with open("../temp/translation_vi_fr_200.json", 'w') as dump_file_tokenized:
    json.dump(json_result, dump_file_tokenized, indent=2, ensure_ascii=True)
print("end dump")
