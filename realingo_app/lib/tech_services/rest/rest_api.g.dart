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

RestSentence _$RestSentenceFromJson(Map<String, dynamic> json) {
  return RestSentence(
    json['uri'] as String,
    json['sentence'] as String,
    json['translation'] as String,
    json['hint'] as String,
  );
}

RestItemToLearn _$RestItemToLearnFromJson(Map<String, dynamic> json) {
  return RestItemToLearn(
    json['uri'] as String,
    json['label'] as String,
    (json['sentences'] as List)
        ?.map((e) =>
            e == null ? null : RestSentence.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

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
