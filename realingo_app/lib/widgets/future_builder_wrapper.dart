import 'package:flutter/material.dart';
import 'package:realingo_app/screens/loading_screen.dart';
import 'package:realingo_app/screens/unexpected_error_screen.dart';

class FutureBuilderWrapper<T> extends StatefulWidget {
  const FutureBuilderWrapper({Key key, this.future, this.childBuilder})
      : super(key: key);

  @override
  _FutureBuilderWrapperState<T> createState() =>
      _FutureBuilderWrapperState<T>(future, childBuilder);

  final Future<T> future;
  final Widget Function(T) childBuilder;
}

class _FutureBuilderWrapperState<T> extends State<FutureBuilderWrapper> {
  final Future<T> future;
  final Widget Function(T) childBuilder;

  _FutureBuilderWrapperState(this.future, this.childBuilder);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return childBuilder(snapshot.data);
        } else if (snapshot.hasError) {
          return UnexpectedErrorScreen();
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
