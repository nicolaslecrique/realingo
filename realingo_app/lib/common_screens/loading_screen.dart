import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';

@immutable
class LoadingScreen extends StatelessWidget {
  final String message;

  const LoadingScreen({Key key, @required this.message}) : super(key: key);

  // #57B4FA
  // #1696F7
  // #93BCF5

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(StandardSizes.medium),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message + '...', style: StandardFonts.bigFunny),
            SizedBox(height: 2 * StandardSizes.medium),
            ClipRRect(
                // https://stackoverflow.com/questions/57534160/how-to-add-a-border-corner-radius-to-a-linearprogressindicator-in-flutter
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  minHeight: StandardSizes.medium,
                ))
          ],
        )),
      ),
    );
  }
}
