import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  static const routeName = '/loading_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("loading")),
    );
  }
}
