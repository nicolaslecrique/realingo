// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestLanguage _$RestLanguageFromJson(Map<String, dynamic> json) {
  return RestLanguage(
    json['uri'] as String,
    json['label'] as String,
  );
}

RestItemTranslation _$RestItemTranslationFromJson(Map<String, dynamic> json) {
  return RestItemTranslation(
    json['translation'] as String,
    json['englishDefinition'] as String,
  );
}

RestItemInSentence _$RestItemInSentenceFromJson(Map<String, dynamic> json) {
  return RestItemInSentence(
    json['startIndex'] as int,
    json['endIndex'] as int,
    json['label'] as String,
    (json['translations'] as List)
        ?.map((e) => e == null
            ? null
            : RestItemTranslation.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

RestSentence _$RestSentenceFromJson(Map<String, dynamic> json) {
  return RestSentence(
    json['uri'] as String,
    json['sentence'] as String,
    json['translation'] as String,
    json['hint'] as String,
    (json['items'] as List)
        ?.map((e) => e == null
            ? null
            : RestItemInSentence.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

RestLesson _$RestLessonFromJson(Map<String, dynamic> json) {
  return RestLesson(
    json['uri'] as String,
    json['label'] as String,
    (json['sentences'] as List)
        ?.map((e) =>
            e == null ? null : RestSentence.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['description'] as String,
  );
}

RestLessonInProgram _$RestLessonInProgramFromJson(Map<String, dynamic> json) {
  return RestLessonInProgram(
    json['uri'] as String,
    json['label'] as String,
    json['description'] as String,
  );
}

RestLearningProgram _$RestLearningProgramFromJson(Map<String, dynamic> json) {
  return RestLearningProgram(
    json['uri'] as String,
    json['originLanguageUri'] as String,
    json['learnedLanguageUri'] as String,
    (json['lessons'] as List)
        ?.map((e) => e == null
            ? null
            : RestLessonInProgram.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}
