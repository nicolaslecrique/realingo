import 'package:flutter/material.dart';
import 'package:realingo_app/common_screens/one_button_screen.dart';

class EndLessonScreen extends StatelessWidget {
  const EndLessonScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OneButtonScreen(
      title: 'Lesson completed',
      child: Center(child: Text('Congratulation')),
      buttonText: "OK",
      onButtonPressed: () => null,
    );
  }
}
