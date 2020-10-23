import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class UnexpectedErrorScreen extends StatelessWidget {
  UnexpectedErrorScreen(Object error) {
    debugPrint(error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Text("Unexpected Error"),
          ElevatedButton(
              onPressed: () => Phoenix.rebirth(context),
              child: Text("Restart app"))
        ],
      )),
    );
  }
}
