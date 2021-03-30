import 'package:flutter/material.dart';
import 'package:realingo_app/common_screens/loading_screen.dart';
import 'package:realingo_app/common_screens/recoverable_error.dart';
import 'package:realingo_app/tech_services/result.dart';

@immutable
class ResultWrapper<T> extends StatefulWidget {
  const ResultWrapper(
      {Key? key, required this.futureResultBuilder, required this.childBuilder, required this.loadingMessage})
      : super(key: key);

  final Future<Result<T>> Function() futureResultBuilder;
  final Widget Function(T) childBuilder;
  final String loadingMessage;

  @override
  _ResultWrapperState<T> createState() => _ResultWrapperState<T>();
}

class _ResultWrapperState<T> extends State<ResultWrapper<T>> {
  Result<T>? _result;

  @override
  void initState() {
    super.initState();
    runResultBuilder().then((value) => null);
  }

  Future<void> runResultBuilder() async {
    setState(() {
      _result = null;
    });
    Result<T> result = await widget.futureResultBuilder();
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null) {
      return LoadingScreen(message: widget.loadingMessage);
    } else if (_result!.isOk) {
      return widget.childBuilder(_result!.result);
    } else {
      return RecoverableError(taskMessage: widget.loadingMessage, retryAction: runResultBuilder);
    }
  }
}
