import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:realingo_app/common_screens/one_button_screen.dart';
import 'package:realingo_app/design/constants.dart';

class RecoverableError extends StatelessWidget {
  final String taskMessage;
  final void Function() retryAction;

  const RecoverableError({Key? key, required this.taskMessage, required this.retryAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OneButtonScreen(
      buttonText: 'Retry',
      onButtonPressed: retryAction,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$taskMessage failed...', style: Theme.of(context).textTheme.headline5),
          SizedBox(height: StandardSizes.medium),
          Text('Are you connected to the internet?', style: Theme.of(context).textTheme.headline5),
        ],
      )),
    );
  }
}
