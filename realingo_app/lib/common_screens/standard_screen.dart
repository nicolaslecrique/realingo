import 'package:flutter/material.dart';
import 'package:realingo_app/design/constants.dart';

@immutable
class StandardScreen extends StatelessWidget {
  final String? titleOrNull;
  final Widget contentChild;
  final Widget bottomChild;

  const StandardScreen({Key? key, this.titleOrNull, required this.contentChild, required this.bottomChild})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: titleOrNull == null
            ? null
            : AppBar(
                title: Text(titleOrNull!),
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
