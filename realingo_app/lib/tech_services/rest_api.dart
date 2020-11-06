import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:realingo_app/tech_services/app_config.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// https://flutter.dev/docs/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'rest_api.g.dart';

@JsonSerializable()
class RestLanguage {
  final String uri;
  final String languageLabel;

  RestLanguage(this.uri, this.languageLabel);

  factory RestLanguage.fromJson(Map<String, dynamic> json) =>
      _$RestLanguageFromJson(json);

  Map<String, dynamic> toJson() => _$RestLanguageToJson(this);
}

@JsonSerializable()
class RestItemToLearn {
  final String uri;
  final String itemLabel;

  RestItemToLearn(this.uri, this.itemLabel);
}

@JsonSerializable()
class RestLearningProgram {
  final String uri;
  final String originLanguageUri;
  final String targetLanguageUri;
  final List<RestItemToLearn> itemsToLearn;

  RestLearningProgram(this.uri, this.originLanguageUri, this.targetLanguageUri,
      this.itemsToLearn);
}

/*
Rest API wrapper
 */
class RestApi {
  static const String _restApiBaseUrl = AppConfig.apiUrl;

  static Future<List<RestLanguage>> getAvailableOriginLanguages(
      String targetLanguageUri) async {
    http.Response response = await http.get(
        "$_restApiBaseUrl/available_origin_languages?target_language_uri=$targetLanguageUri");

    final languages = (json.decode(response.body) as List)
        .map((i) => RestLanguage.fromJson(i))
        .toList();

    return languages;
  }

  static Future<List<RestLanguage>> getAvailableTargetLanguages() async {
    http.Response response =
        await http.get("$_restApiBaseUrl/available_target_languages");

    final languages = (json.decode(response.body) as List)
        .map((i) => RestLanguage.fromJson(i))
        .toList();

    return languages;
  }

  static Future<RestLearningProgram> getProgram(
      String targetLanguageUri, String originLanguageUri) async {
    http.Response response = await http.get(
        "$_restApiBaseUrl/program?target_language_uri=$targetLanguageUri&origin_language_uri=$originLanguageUri");
    final program = json.decode(response.body);
    return program;
  }
}
