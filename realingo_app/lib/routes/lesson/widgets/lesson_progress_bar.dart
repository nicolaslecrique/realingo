import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';

class LessonProgressBar extends StatelessWidget {
  final double ratioCompleted;

  const LessonProgressBar({Key key, this.ratioCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: ratioCompleted, minHeight: StandardSizes.small);
  }
}
