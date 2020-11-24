class Language {
  final String uri;
  final String label;

  Language(this.uri, this.label);
}

class ItemToLearnSentence {
  final String uri;
  final String sentence;
  final String translation;

  ItemToLearnSentence(this.uri, this.sentence, this.translation);
}

class ItemToLearn {
  final String uri;
  final String label;
  final List<ItemToLearnSentence> sentences;

  ItemToLearn(this.uri, this.label, this.sentences);
}

class LearningProgram {
  final String uri;
  final List<ItemToLearn> itemsToLearn;

  LearningProgram(this.uri, this.itemsToLearn);
}
