import 'package:flutter/material.dart';

class OneButtonScreen extends StatelessWidget {
  final VoidCallback onButtonPressed;
  final String title;
  final String buttonText;
  final Widget child;

  OneButtonScreen(
      {this.child, this.title, this.buttonText, this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.title),
          automaticallyImplyLeading: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: <Widget>[
                this.child,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("OK"),
                    onPressed: this.onButtonPressed,
                  ),
                )
              ],
            )));
  }
}
