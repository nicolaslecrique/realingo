from dataclasses import dataclass

from languages_toolboxes.vietnamese_toolbox import VietnameseToolbox
from program_data_builder import build_program_data, LanguageProgramData


@dataclass(frozen=True)
class LanguageProgram:
    pass


program_data: LanguageProgramData = build_program_data("vietnamese", VietnameseToolbox())
print(program_data)
