import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';
import 'package:realingo_app/model/user_program.dart';
import 'package:realingo_app/model/user_program_model.dart';
import 'package:realingo_app/routes/lesson/lesson_route.dart';

enum LessonInProgramStatus { Learned, Current, NotLearned }

class LessonCard extends StatelessWidget {
  final LessonInProgram lessonInProgram;
  final LessonInProgramStatus status;

  const LessonCard({Key? key, required this.lessonInProgram, required this.status}) : super(key: key);

  Future<void> startLesson(BuildContext context) async {
    UserProgramModel model = Provider.of<UserProgramModel>(context, listen: false);
    UserLearningProgram userProgram = model.programOrNull!;

    LessonRouteArgs lessonRouteArgs = LessonRouteArgs(userProgram.program, userProgram.nextLesson);
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
        onTap: status == LessonInProgramStatus.Current
            ? () => startLesson(context)
            : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lesson already completed'), duration: Duration(milliseconds: 500))),
        trailing: icon,
        enabled: status != LessonInProgramStatus.NotLearned,
        selected: status == LessonInProgramStatus.Current,
      ),
    );
  }
}
