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
    (json['translations'] as List<dynamic>)
        .map((e) => RestItemTranslation.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

RestSentence _$RestSentenceFromJson(Map<String, dynamic> json) {
  return RestSentence(
    json['uri'] as String,
    json['sentence'] as String,
    json['translation'] as String,
    json['hint'] as String,
    (json['items'] as List<dynamic>)
        .map((e) => RestItemInSentence.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

RestExercise _$RestExerciseFromJson(Map<String, dynamic> json) {
  return RestExercise(
    json['uri'] as String,
    _$enumDecode(_$RestExerciseTypeEnumMap, json['exerciseType']),
    RestSentence.fromJson(json['sentence'] as Map<String, dynamic>),
  );
}

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$RestExerciseTypeEnumMap = {
  RestExerciseType.TranslateToLearningLanguage: 'TranslateToLearningLanguage',
  RestExerciseType.Repeat: 'Repeat',
};

RestLesson _$RestLessonFromJson(Map<String, dynamic> json) {
  return RestLesson(
    json['uri'] as String,
    json['label'] as String,
    (json['exercises'] as List<dynamic>)
        .map((e) => RestExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
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
    (json['lessons'] as List<dynamic>)
        .map((e) => RestLessonInProgram.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
