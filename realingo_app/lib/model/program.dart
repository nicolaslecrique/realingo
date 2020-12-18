import 'package:flutter/cupertino.dart';

@immutable
class Language {
  final String uri;
  final String label;

  const Language(this.uri, this.label);
}

@immutable
class ItemToLearnSentence {
  final String uri;
  final String sentence;
  final String translation;
  final String hint;

  const ItemToLearnSentence(this.uri, this.sentence, this.translation, this.hint);
}

@immutable
class ItemToLearn {
  final String uri;
  final String label;
  final List<ItemToLearnSentence> sentences;

  const ItemToLearn(this.uri, this.label, this.sentences);
}

@immutable
class LearningProgram {
  final String uri;
  final List<ItemToLearn> itemsToLearn;

  const LearningProgram(this.uri, this.itemsToLearn);
}
