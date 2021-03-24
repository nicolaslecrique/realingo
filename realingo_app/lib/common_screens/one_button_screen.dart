import 'package:flutter/material.dart';
import 'package:realingo_app/common_screens/standard_screen.dart';

@immutable
class OneButtonScreen extends StatelessWidget {
  final VoidCallback onButtonPressed;
  final String? titleOrNull;
  final String buttonText;
  final Widget child;

  const OneButtonScreen(
      {Key? key, required this.child, this.titleOrNull, required this.buttonText, required this.onButtonPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StandardScreen(
      titleOrNull: titleOrNull,
      contentChild: child,
      bottomChild: ElevatedButton(
        onPressed: onButtonPressed,
        child: Text(buttonText),
      ),
    );
  }
}
