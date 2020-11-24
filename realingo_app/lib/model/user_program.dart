enum UserItemToLearnStatus { KnownAtStart, NotLearned }

class UserItemToLearnSentence {
  final String uri;
  final String serverUri;
  final String sentence;
  final String translation;

  UserItemToLearnSentence(this.uri, this.serverUri, this.sentence, this.translation);
}

class UserItemToLearn {
  final String uri;
  final String serverUri;
  final String label;

  final List<UserItemToLearnSentence> sentences;
  final UserItemToLearnStatus status;

  UserItemToLearn(this.uri, this.serverUri, this.label, this.sentences, this.status);
}

class UserLearningProgram {
  final String uri;
  final String serverUri;
  final List<UserItemToLearn> itemsToLearn;

  UserLearningProgram(this.uri, this.serverUri, this.itemsToLearn);
}
