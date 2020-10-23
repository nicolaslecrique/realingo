import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:realingo_app/tech_services/app_config.dart';

// command to run generation watch: ../../../../tools/flutter/flutter/bin/flutter pub run build_runner watch
// https://flutter.dev/docs/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'rest_api.g.dart';

@JsonSerializable()
class RestLanguage {
  final String languageUri;
  final String languageLabel;

  RestLanguage(this.languageUri, this.languageLabel);

  factory RestLanguage.fromJson(Map<String, dynamic> json) =>
      _$RestLanguageFromJson(json);

  Map<String, dynamic> toJson() => _$RestLanguageToJson(this);
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
}
