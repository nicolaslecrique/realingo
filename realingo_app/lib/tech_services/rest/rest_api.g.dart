// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestLanguage _$RestLanguageFromJson(Map<String, dynamic> json) {
  return RestLanguage(
    json['uri'] as String,
    json['label'] as String,
  );
}

Map<String, dynamic> _$RestLanguageToJson(RestLanguage instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'label': instance.label,
    };

RestItemToLearn _$RestItemToLearnFromJson(Map<String, dynamic> json) {
  return RestItemToLearn(
    json['uri'] as String,
    json['label'] as String,
  );
}

Map<String, dynamic> _$RestItemToLearnToJson(RestItemToLearn instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'label': instance.label,
    };

RestLearningProgram _$RestLearningProgramFromJson(Map<String, dynamic> json) {
  return RestLearningProgram(
    json['uri'] as String,
    json['originLanguageUri'] as String,
    json['learnedLanguageUri'] as String,
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
      'learnedLanguageUri': instance.learnedLanguageUri,
      'itemsToLearn': instance.itemsToLearn,
    };
