import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/app_config.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// or to not watch but ust build one shot:  ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build
// https://flutter.dev/docs/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'rest_api.g.dart';

@JsonSerializable(createToJson: false)
class RestLanguage {
  final String uri;
  final String label;

  RestLanguage(this.uri, this.label);

  factory RestLanguage.fromJson(Map<String, dynamic> json) => _$RestLanguageFromJson(json);
}

@JsonSerializable(createToJson: false)
class RestSentence {
  final String uri;
  final String sentence;
  final String translation;

  RestSentence(this.uri, this.sentence, this.translation);

  factory RestSentence.fromJson(Map<String, dynamic> json) => _$RestSentenceFromJson(json);
}

@JsonSerializable(createToJson: false)
class RestItemToLearn {
  final String uri;
  final String label;
  final List<RestSentence> sentences;

  RestItemToLearn(this.uri, this.label, this.sentences);

  factory RestItemToLearn.fromJson(Map<String, dynamic> json) => _$RestItemToLearnFromJson(json);
}

@JsonSerializable(createToJson: false)
class RestLearningProgram {
  final String uri;
  final String originLanguageUri;
  final String learnedLanguageUri;
  final List<RestItemToLearn> itemsToLearn;

  RestLearningProgram(this.uri, this.originLanguageUri, this.learnedLanguageUri, this.itemsToLearn);

  factory RestLearningProgram.fromJson(Map<String, dynamic> json) => _$RestLearningProgramFromJson(json);
}

/*
Rest API wrapper
 */
class RestApi {
  static const String _restApiBaseUrl = "${AppConfig.apiUrl}/api/v0";

  static Future<List<Language>> getAvailableOriginLanguages(String learnedLanguageUri) async {
    http.Response response =
        await http.get("$_restApiBaseUrl/available_origin_languages?learned_language_uri=$learnedLanguageUri");

    final languages = (json.decode(response.body) as List)
        .map((i) => RestLanguage.fromJson(i))
        .map((e) => Language(e.uri, e.label))
        .toList();

    return languages;
  }

  static Future<List<Language>> getAvailableLearnedLanguages() async {
    http.Response response = await http.get("$_restApiBaseUrl/available_learned_languages");

    final languages = (json.decode(response.body) as List)
        .map((i) => RestLanguage.fromJson(i))
        .map((e) => Language(e.uri, e.label))
        .toList();

    return languages;
  }

  static Future<LearningProgram> getProgram(String learnedLanguageUri, String originLanguageUri) async {
    http.Response response = await http.get(
        "$_restApiBaseUrl/program?learned_language_uri=$learnedLanguageUri&origin_language_uri=$originLanguageUri");
    final restProgram = RestLearningProgram.fromJson(json.decode(response.body));

    final items = restProgram.itemsToLearn
        .map((e) => ItemToLearn(
            e.uri, e.label, e.sentences.map((s) => ItemToLearnSentence(s.uri, s.sentence, s.translation)).toList()))
        .toList();
    return LearningProgram(restProgram.uri, items);
  }
}