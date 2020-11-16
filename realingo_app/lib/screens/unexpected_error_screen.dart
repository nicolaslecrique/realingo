import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class UnexpectedErrorScreen extends StatelessWidget {
  final Object error;

  UnexpectedErrorScreen(this.error) {
    debugPrint(error.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Text("Unexpected Error: " + error.toString()),
          ElevatedButton(onPressed: () => Phoenix.rebirth(context), child: Text("Restart app"))
        ],
      )),
    );
  }
}
