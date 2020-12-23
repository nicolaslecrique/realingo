import 'package:flutter/cupertino.dart';
import 'package:realingo_app/model/program.dart';

enum UserItemToLearnStatus { SkippedAtStart, Learned, Skipped, NotLearned }

@immutable
class UserItemToLearnSentence {
  final String uri;
  final String serverUri;
  final String sentence;
  final String translation;
  final String hint;

  const UserItemToLearnSentence(this.uri, this.serverUri, this.sentence, this.translation, this.hint);
}

@immutable
class UserItemToLearn {
  final String uri;
  final String serverUri;
  final String label;

  final List<UserItemToLearnSentence> sentences;
  final UserItemToLearnStatus status;

  const UserItemToLearn(this.uri, this.serverUri, this.label, this.sentences, this.status);
}

@immutable
class UserLearningProgram {
  final String uri;
  final String serverUri;
  final List<UserItemToLearn> itemsToLearn;
  final Language learnedLanguage;
  final Language originLanguage;

  const UserLearningProgram(this.uri, this.serverUri, this.itemsToLearn, this.learnedLanguage, this.originLanguage);
}
