import 'package:flutter/material.dart';
import 'package:realingo_app/common_screens/loading_screen.dart';
import 'package:realingo_app/common_screens/unexpected_error_screen.dart';

@immutable
class FutureBuilderWrapper<T> extends StatelessWidget {
  const FutureBuilderWrapper({Key key, this.future, this.childBuilder}) : super(key: key);

  final Future<T> future;
  final Widget Function(T) childBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return childBuilder(snapshot.data);
        } else if (snapshot.hasError) {
          return UnexpectedErrorScreen(snapshot.error);
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
