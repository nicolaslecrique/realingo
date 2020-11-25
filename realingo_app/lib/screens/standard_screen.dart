import 'package:flutter/material.dart';

class StandardScreen extends StatelessWidget {
  final String title;
  final Widget contentChild;
  final Widget bottomChild;

  const StandardScreen({Key key, this.title, this.contentChild, this.bottomChild}) : super(key: key);

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
                Expanded(child: this.contentChild),
                SizedBox(
                  width: double.infinity,
                  child: bottomChild,
                )
              ],
            )));
  }
}
