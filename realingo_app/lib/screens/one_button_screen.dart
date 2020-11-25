import 'package:flutter/material.dart';
import 'package:realingo_app/screens/standard_screen.dart';

class OneButtonScreen extends StatelessWidget {
  final VoidCallback onButtonPressed;
  final String title;
  final String buttonText;
  final Widget child;

  OneButtonScreen(
      {Key key, @required this.child, @required this.title, @required this.buttonText, @required this.onButtonPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StandardScreen(
      title: title,
      contentChild: child,
      bottomChild: ElevatedButton(
        child: Text(this.buttonText),
        onPressed: this.onButtonPressed,
      ),
    );
  }
}
