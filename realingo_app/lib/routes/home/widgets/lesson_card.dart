import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';
import 'package:realingo_app/model/program.dart';

enum LessonInProgramStatus { Learned, Current, NotLearned }

class LessonCard extends StatelessWidget {
  final LessonInProgram lessonInProgram;
  final LessonInProgramStatus status;

  const LessonCard({Key key, @required this.lessonInProgram, @required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Icon icon;
    switch (status) {
      case LessonInProgramStatus.Learned:
        icon = Icon(
          Icons.check,
          color: StandardColors.brandBlue,
        );
        break;
      case LessonInProgramStatus.Current:
        icon = null;
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
          'traduction',
          style: StandardFonts.wordItem,
        ),
        onTap: () => null,
        trailing: icon,
      ),
    );
  }
}
