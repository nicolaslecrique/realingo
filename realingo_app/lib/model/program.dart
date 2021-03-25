import 'package:flutter/cupertino.dart';

@immutable
class Language {
  final String uri;
  final String label;

  const Language(this.uri, this.label);
}

// ------- Lesson -----------

@immutable
class ItemTranslation {
  final String translation;
  final String englishDefinition;

  const ItemTranslation(this.translation, this.englishDefinition);
}

@immutable
class ItemInSentence {
  final int startIndex;
  final int endIndex;
  final String label;
  final List<ItemTranslation> translations;

  const ItemInSentence(this.startIndex, this.endIndex, this.label, this.translations);
}

@immutable
class Sentence {
  final String uri;
  final String sentence;
  final String translation;
  final String hint;
  final List<ItemInSentence> items;

  const Sentence(this.uri, this.sentence, this.translation, this.hint, this.items);
}

enum ExerciseType { TranslateToLearningLanguage, Repeat }

@immutable
class Exercise {
  final String uri;
  final ExerciseType exerciseType;
  final Sentence sentence;

  const Exercise(this.uri, this.exerciseType, this.sentence);
}

@immutable
class Lesson {
  final String uri;
  final String label;
  final String description;
  final List<Exercise> exercises;

  const Lesson(this.uri, this.label, this.description, this.exercises);
}

// --------- Program -----------

@immutable
class LessonInProgram {
  final String uri;
  final String label;
  final String description;

  const LessonInProgram(this.uri, this.label, this.description);
}

@immutable
class LearningProgram {
  final String uri;
  final String learnedLanguageUri;
  final String originLanguageUri;
  final List<LessonInProgram> lessons;

  const LearningProgram(this.uri, this.learnedLanguageUri, this.originLanguageUri, this.lessons);
}
