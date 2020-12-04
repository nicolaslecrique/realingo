import 'package:flutter/material.dart';

@immutable
class LoadingScreen extends StatelessWidget {
  final String message;

  const LoadingScreen({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
