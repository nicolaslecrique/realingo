from vncorenlp import VnCoreNLP
from typing import List, Dict, Generator
import json

# https://stackoverflow.com/questions/17314506/why-do-i-need-a-tokenizer-for-each-language

# https://github.com/datquocnguyen/RDRsegmenter

# To perform word segmentation, POS tagging and then NER
# annotator = VnCoreNLP("<FULL-PATH-to-VnCoreNLP-jar-file>", annotators="wseg,pos,ner", max_heap_size='-Xmx2g')
# To perform word segmentation and then POS tagging
# annotator = VnCoreNLP("<FULL-PATH-to-VnCoreNLP-jar-file>", annotators="wseg,pos", max_heap_size='-Xmx2g')
# To perform word segmentation only
# annotator = VnCoreNLP("<FULL-PATH-to-VnCoreNLP-jar-file>", annotators="wseg", max_heap_size='-Xmx500m')
with VnCoreNLP("/Users/nicolas/dev/realingo/tools/VnCoreNLP/VnCoreNLP-1.1.1.jar", annotators='wseg,pos', max_heap_size='-Xmx4g') as vncorenlp:

    print("open file")
    #with open ("data/open_subtitles_vietnamese.txt", "r") as myfile:
    with open ("data/open_subtitles_vietnamese_sample.txt", "r") as myfile:

        print("start readlines")
        data: List[str]=myfile.readlines()

        # Input
        # text = "Ông Nguyễn Khắc Chúc  đang làm việc tại Đại học Quốc gia Hà Nội" \
        #       "\r\n Bà Lan, vợ ông Chúc, cũng làm việc tại đây."
        print("start annotate")
        annotated_lines = [vncorenlp.annotate(line) for line in data if vncorenlp.detect_language(line) == 'vi']
        print("end annotate")
        print("start dump")
        with open("temp/open_subtitles_vietnamese_annotated.json", 'w') as dump_file_tokenized:
            json.dump(annotated_lines, dump_file_tokenized, indent=2)
        print("end dump")


