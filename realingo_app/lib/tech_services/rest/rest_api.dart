import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/tech_services/app_config.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// or to not watch but ust build one shot:  ../../../../tools/flutter/flutter/bin/flutter pub run build_runner build
// https://flutter.dev/docs/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'rest_api.g.dart';

@JsonSerializable()
class RestLanguage {
  final String uri;
  final String languageLabel;

  RestLanguage(this.uri, this.languageLabel);

  factory RestLanguage.fromJson(Map<String, dynamic> json) => _$RestLanguageFromJson(json);

  Map<String, dynamic> toJson() => _$RestLanguageToJson(this);
}

@JsonSerializable()
class RestItemToLearn {
  final String uri;
  final String itemLabel;

  RestItemToLearn(this.uri, this.itemLabel);

  factory RestItemToLearn.fromJson(Map<String, dynamic> json) => _$RestItemToLearnFromJson(json);

  Map<String, dynamic> toJson() => _$RestItemToLearnToJson(this);
}

@JsonSerializable()
class RestLearningProgram {
  final String uri;
  final String originLanguageUri;
  final String targetLanguageUri;
  final List<RestItemToLearn> itemsToLearn;

  RestLearningProgram(this.uri, this.originLanguageUri, this.targetLanguageUri, this.itemsToLearn);

  factory RestLearningProgram.fromJson(Map<String, dynamic> json) => _$RestLearningProgramFromJson(json);

  Map<String, dynamic> toJson() => _$RestLearningProgramToJson(this);
}

/*
Rest API wrapper
 */
class RestApi {
  static const String _restApiBaseUrl = AppConfig.apiUrl;

  static Future<List<Language>> getAvailableOriginLanguages(String targetLanguageUri) async {
    http.Response response =
        await http.get("$_restApiBaseUrl/available_origin_languages?target_language_uri=$targetLanguageUri");

    final languages = (json.decode(response.body) as List)
        .map((i) => RestLanguage.fromJson(i))
        .map((e) => Language(e.uri, e.languageLabel))
        .toList();

    return languages;
  }

  static Future<List<Language>> getAvailableTargetLanguages() async {
    http.Response response = await http.get("$_restApiBaseUrl/available_target_languages");

    final languages = (json.decode(response.body) as List)
        .map((i) => RestLanguage.fromJson(i))
        .map((e) => Language(e.uri, e.languageLabel))
        .toList();

    return languages;
  }

  static Future<LearningProgram> getProgram(String targetLanguageUri, String originLanguageUri) async {
    http.Response response = await http
        .get("$_restApiBaseUrl/program?target_language_uri=$targetLanguageUri&origin_language_uri=$originLanguageUri");
    final restProgram = RestLearningProgram.fromJson(json.decode(response.body));

    final items = restProgram.itemsToLearn.map((e) => ItemToLearn(e.uri, e.itemLabel)).toList();
    return LearningProgram(restProgram.uri, items);
  }
}
