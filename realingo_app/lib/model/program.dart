
class Language {
  final String uri;
  final String label;

  Language(this.uri, this.label);
}

class ItemToLearn {
  final String uri;
  final String label;

  ItemToLearn(this.uri, this.label);
}

class LearningProgram {
  final String uri;
  final List<ItemToLearn> itemsToLearn;

  LearningProgram(this.uri, this.itemsToLearn);
}

class UserProgram {
  final String uri;
  final LearningProgram program;

  UserProgram(this.uri, this.program);
}