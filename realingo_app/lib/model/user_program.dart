import 'package:flutter/cupertino.dart';
import 'package:realingo_app/model/program.dart';

@immutable
class UserLearningProgram {
  final LearningProgram program;
  final Lesson nextLesson;

  const UserLearningProgram(this.program, this.nextLesson);
}
