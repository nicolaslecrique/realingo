import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';

class LessonProgressBar extends StatelessWidget {
  final double ratioCompleted;

  const LessonProgressBar({Key? key, required this.ratioCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        // https://stackoverflow.com/questions/57534160/how-to-add-a-border-corner-radius-to-a-linearprogressindicator-in-flutter
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
          value: ratioCompleted,
          minHeight: StandardSizes.medium,
        ));
  }
}
