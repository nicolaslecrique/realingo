from typing import List, Dict, Generator
import json

# Associate to each word in the frequency list
# all the sentences for which this word is the less frequent


with open("data/open_subtitles_vietnamese_annotated.json") as json_file:
    print("load json file")
    json_str = json_file.read()
    print("load json str into dict")
    open_subtitles_vientamese_annotated: Dict = json.loads(json_str)
