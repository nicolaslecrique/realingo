import 'package:flutter/material.dart';

class LessonProgressBar extends StatelessWidget {
  final double ratioCompleted;

  const LessonProgressBar({Key key, this.ratioCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: ratioCompleted);
  }
}
