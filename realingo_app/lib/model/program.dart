class Language {
  final String uri;
  final String label;

  Language(this.uri, this.label);
}

enum UserItemToLearnStatus { KnownAtStart, NotLearned }

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

class UserItemToLearn {
  final String uri;
  final UserItemToLearnStatus status;

  final ItemToLearn itemToLearn;

  UserItemToLearn(this.uri, this.itemToLearn, this.status);
}

class UserLearningProgram {
  final String uri;
  final String learningProgramServerUri;
  final List<UserItemToLearn> itemsToLearn;

  UserLearningProgram(this.uri, this.learningProgramServerUri, this.itemsToLearn);
}
