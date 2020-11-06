import 'package:realingo_app/tech_services/rest_api.dart';

class Language {
  final String uri;
  final String languageLabel;

  Language(this.uri, this.languageLabel);
}

class ItemToLearn {
  final String uri;
  final String itemLabel;

  ItemToLearn(this.uri, this.itemLabel);
}

class LearningProgram {
  final String uri;
  final List<ItemToLearn> itemsToLearn;

  LearningProgram(this.uri, this.itemsToLearn);
}

class ProgramServices {
  static Future<List<Language>> getAvailableTargetLanguages() async {
    return (await RestApi.getAvailableTargetLanguages())
        .map((l) => Language(l.uri, l.languageLabel))
        .toList();
  }

  static Future<List<Language>> getAvailableOriginLanguages(
      Language targetLanguage) async {
    return (await RestApi.getAvailableOriginLanguages(targetLanguage.uri))
        .map((l) => Language(l.uri, l.languageLabel))
        .toList();
  }

  static Future<LearningProgram> getProgram(
      Language targetLanguage, Language originLanguage) async {
    RestLearningProgram restProgram =
        await RestApi.getProgram(targetLanguage.uri, originLanguage.uri);

    return new LearningProgram(
        restProgram.uri,
        restProgram.itemsToLearn
            .map((e) => ItemToLearn(e.uri, e.itemLabel))
            .toList(growable: false));
  }
}
