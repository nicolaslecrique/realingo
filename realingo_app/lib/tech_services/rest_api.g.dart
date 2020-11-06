// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestLanguage _$RestLanguageFromJson(Map<String, dynamic> json) {
  return RestLanguage(
    json['uri'] as String,
    json['languageLabel'] as String,
  );
}

Map<String, dynamic> _$RestLanguageToJson(RestLanguage instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'languageLabel': instance.languageLabel,
    };

RestItemToLearn _$RestItemToLearnFromJson(Map<String, dynamic> json) {
  return RestItemToLearn(
    json['uri'] as String,
    json['itemLabel'] as String,
  );
}

Map<String, dynamic> _$RestItemToLearnToJson(RestItemToLearn instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'itemLabel': instance.itemLabel,
    };

RestLearningProgram _$RestLearningProgramFromJson(Map<String, dynamic> json) {
  return RestLearningProgram(
    json['uri'] as String,
    json['originLanguageUri'] as String,
    json['targetLanguageUri'] as String,
    (json['itemsToLearn'] as List)
        ?.map((e) => e == null
            ? null
            : RestItemToLearn.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$RestLearningProgramToJson(
        RestLearningProgram instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'originLanguageUri': instance.originLanguageUri,
      'targetLanguageUri': instance.targetLanguageUri,
      'itemsToLearn': instance.itemsToLearn,
    };
