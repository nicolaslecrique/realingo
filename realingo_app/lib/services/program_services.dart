import 'package:realingo_app/tech_services/rest_api.dart';

class Language {
  final String languageUri;
  final String languageLabel;

  Language(this.languageUri, this.languageLabel);
}

class ProgramServices {
  static Future<List<Language>> getAvailableTargetLanguages() async {
    return (await RestApi.getAvailableTargetLanguages())
        .map((l) => Language(l.languageUri, l.languageLabel))
        .toList();
  }
}
