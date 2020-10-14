import json

from language_data_builder import LanguageData, build_language_data_from_file
from languages_toolboxes.api_language_toolbox import Language


language_data: LanguageData = build_language_data_from_file(
    "temp/extracted_sentences_vietnamese_200.json",
    language=Language.VIETNAMESE)

json_language_data = language_data.to_dict()

print("start dump")
with open("temp/language_data_vietnamese_200.json", 'w') as dump_file_tokenized:
    json.dump(json_language_data, dump_file_tokenized, indent=2, ensure_ascii=False)
print("end dump")
