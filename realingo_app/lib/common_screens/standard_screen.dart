import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';

@immutable
class StandardScreen extends StatelessWidget {
  final String title;
  final Widget contentChild;
  final Widget bottomChild;

  const StandardScreen({Key key, this.title, this.contentChild, this.bottomChild}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(StandardSizes.medium),
            child: Column(
              children: <Widget>[
                Expanded(child: contentChild),
                SizedBox(height: StandardSizes.medium),
                SizedBox(
                  width: double.infinity,
                  child: bottomChild,
                )
              ],
            )));
  }
}
