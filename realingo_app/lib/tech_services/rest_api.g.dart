// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestLanguage _$RestLanguageFromJson(Map<String, dynamic> json) {
  return RestLanguage(
    json['languageUri'] as String,
    json['languageLabel'] as String,
  );
}

Map<String, dynamic> _$RestLanguageToJson(RestLanguage instance) =>
    <String, dynamic>{
      'languageUri': instance.languageUri,
      'languageLabel': instance.languageLabel,
    };
