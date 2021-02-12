import json

# 1) iterate on all sentences
# 2) translate them and translate them ack
# 3) write them batch by batch in jsonl file (in case it fails)
import os
from typing import List

from translator import Translator, TranslatedSentence

# NB: Se connecter en ssh: ssh nicolas@35.227.175.180
# copy files
# gcloud compute scp main.py deeplearning-1-vm:~/translator/main.py
# gcloud compute scp translation_evaluator.py deeplearning-1-vm:~/translator/translation_evaluator.py
# gcloud compute scp translator.py deeplearning-1-vm:~/translator/translator.py
# gcloud compute scp requirements.txt deeplearning-1-vm:~/translator/requirements.txt
# gcloud compute scp --recurse data deeplearning-1-vm:~/translator/data

# Launch so that it continues even after ssh session end
# nohup python main.py &

# see if it is still running as it should
# wc -l ./tmp/vietnamese/open_subtitles_translated.jsonl

# To dowload generated file from VM
# gcloud compute scp nicolas@deeplearning-1-vm:~/translator/tmp/vietnamese/open_subtitles_translated.jsonl .

with open("./data/vietnamese/open_subtitles.txt") as sentences_file:
    lines: List[str] = sentences_file.read().splitlines()

translator: Translator = Translator("vi", "en")

batch_size = 16

cache_to_print_size = 32
dest_file: str = "./tmp/vietnamese/open_subtitles_translated.jsonl"
current_line_index = 0
if os.path.exists(dest_file):
    with open(dest_file, encoding="utf-8") as translated_file:
        last_line: str = translated_file.readlines()[-1]
        last_translated: TranslatedSentence = TranslatedSentence.from_json(last_line)
        last_line_index = lines.index(last_translated.original_sentence)
        current_line_index = last_line_index + 1

cache_to_print: List[str] = []

while current_line_index < len(lines):
    end_line_index = current_line_index + batch_size
    try:
        batch_lines = lines[current_line_index:end_line_index]
        translated: List[TranslatedSentence] = translator.translate(batch_lines)
        batch_json_lines: List[str] = [t.to_json(ensure_ascii=False) + "\n" for t in translated]
        cache_to_print.extend(batch_json_lines)

        if len(cache_to_print) > cache_to_print_size:
            print(f"print line {current_line_index}")
            with open(dest_file, "a+", encoding="utf-8") as translated_file:
                translated_file.writelines(cache_to_print)
            cache_to_print = []
    except ValueError as e:
        print(f"error at line {current_line_index}: '{e}'")

    current_line_index = end_line_index
