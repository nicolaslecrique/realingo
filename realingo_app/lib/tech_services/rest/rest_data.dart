import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

// command to run generation watch: flutter pub run build_runner watch
// or to not watch but ust build one shot:  flutter pub run build_runner build
// https://flutter.dev/docs/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'rest_data.g.dart';

// ------ Language --------

@JsonSerializable(createToJson: false)
@immutable
class RestLanguage {
  final String uri;
  final String label;

  const RestLanguage(this.uri, this.label);

  factory RestLanguage.fromJson(Map<String, dynamic> json) => _$RestLanguageFromJson(json);
}

// ------- Lesson -----------

@JsonSerializable(createToJson: false)
@immutable
class RestItemTranslation {
  final String translation;
  final String englishDefinition;

  const RestItemTranslation(this.translation, this.englishDefinition);

  factory RestItemTranslation.fromJson(Map<String, dynamic> json) => _$RestItemTranslationFromJson(json);
}

@JsonSerializable(createToJson: false)
@immutable
class RestItemInSentence {
  final int startIndex;
  final int endIndex;
  final String label;
  final List<RestItemTranslation> translations;

  const RestItemInSentence(this.startIndex, this.endIndex, this.label, this.translations);

  factory RestItemInSentence.fromJson(Map<String, dynamic> json) => _$RestItemInSentenceFromJson(json);
}

@JsonSerializable(createToJson: false)
@immutable
class RestSentence {
  final String uri;
  final String sentence;
  final String translation;
  final String hint;
  final List<RestItemInSentence> items;

  const RestSentence(this.uri, this.sentence, this.translation, this.hint, this.items);

  factory RestSentence.fromJson(Map<String, dynamic> json) => _$RestSentenceFromJson(json);
}

@JsonSerializable(createToJson: false)
@immutable
class RestLesson {
  final String uri;
  final String label;
  final String description;
  final List<RestSentence> sentences;

  const RestLesson(this.uri, this.label, this.sentences, this.description);

  factory RestLesson.fromJson(Map<String, dynamic> json) => _$RestLessonFromJson(json);
}

// --------- Program -----------

@JsonSerializable(createToJson: false)
@immutable
class RestLessonInProgram {
  final String uri;
  final String label;
  final String description;

  const RestLessonInProgram(this.uri, this.label, this.description);

  factory RestLessonInProgram.fromJson(Map<String, dynamic> json) => _$RestLessonInProgramFromJson(json);
}

@JsonSerializable(createToJson: false)
@immutable
class RestLearningProgram {
  final String uri;
  final String originLanguageUri;
  final String learnedLanguageUri;
  final List<RestLessonInProgram> lessons;

  const RestLearningProgram(this.uri, this.originLanguageUri, this.learnedLanguageUri, this.lessons);

  factory RestLearningProgram.fromJson(Map<String, dynamic> json) => _$RestLearningProgramFromJson(json);
}
