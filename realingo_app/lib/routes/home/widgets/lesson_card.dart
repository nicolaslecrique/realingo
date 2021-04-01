import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/routes/lesson/lesson_route.dart';

enum LessonInProgramStatus { Learned, Current, NotLearned }

class LessonCard extends StatelessWidget {
  final UserLearningProgram program;
  final LessonInProgram lessonInProgram;
  final LessonInProgramStatus status;

  const LessonCard({Key? key, required this.program, required this.lessonInProgram, required this.status})
      : super(key: key);

  Future<void> startLesson(BuildContext context) async {
    LessonRouteArgs lessonRouteArgs = LessonRouteArgs(program, lessonInProgram);
    await Navigator.pushNamed(context, LessonRoute.route, arguments: lessonRouteArgs);
  }

  @override
  Widget build(BuildContext context) {
    Icon? icon;
    switch (status) {
      case LessonInProgramStatus.Learned:
        icon = Icon(
          Icons.check_circle,
          color: StandardColors.correct,
        );
        break;
      case LessonInProgramStatus.Current:
        icon = Icon(
          Icons.play_circle_fill,
          color: StandardColors.brandBlue,
        );
        break;
      case LessonInProgramStatus.NotLearned:
        icon = null;
        break;
    }

    return Card(
      child: ListTile(
        visualDensity: VisualDensity.compact,
        title: Text(
          lessonInProgram.label,
          style: StandardFonts.wordItem,
        ),
        subtitle: Text(
          lessonInProgram.description,
          style: StandardFonts.wordItem,
        ),
        onTap: () => startLesson(context),
        trailing: icon,
        enabled: status != LessonInProgramStatus.NotLearned,
        selected: status == LessonInProgramStatus.Current,
      ),
    );
  }
}
