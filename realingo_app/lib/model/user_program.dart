import 'package:flutter/cupertino.dart';
import 'package:realingo_app/model/program.dart';

@immutable
class UserLearningProgram {
  final LearningProgram program;
  final String nextLessonUri;

  const UserLearningProgram(this.program, this.nextLessonUri);
}
