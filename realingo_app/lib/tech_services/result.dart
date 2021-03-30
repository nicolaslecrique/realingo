import 'package:flutter/foundation.dart';

enum AppError { RestRequestFailed }

@immutable
class Result<T> {
  final T? _result;
  final AppError? _error;

  const Result(this._result, this._error);

  factory Result.ko(AppError error) {
    return Result(null, error);
  }

  factory Result.ok(T result) {
    return Result(result, null);
  }

  bool get isOk => _error == null;

  T get result => _result!;
  AppError get error => _error!;

  static Result<U> mergeWrap<U, T1, T2>(Result<T1> res1, T2 val2, U Function(T1 ok1, T2 ok2) builder) {
    if (res1.isOk) {
      return Result.ok(builder(res1.result, val2));
    } else {
      return Result.ko(res1.error);
    }
  }

  static Result<U> merge<U, T1, T2>(Result<T1> res1, Result<T2> res2, U Function(T1 ok1, T2 ok2) builder) {
    if (res1.isOk) {
      if (res2.isOk) {
        return Result.ok(builder(res1.result, res2.result));
      } else {
        return Result.ko(res2.error);
      }
    } else {
      return Result.ko(res1.error);
    }
  }

  static Result<U> mergeList<U, T>(Iterable<Result<T>> results, U Function(Iterable<T> ok) builder) {
    Result<T>? firstKo = results.cast<Result<T>?>().firstWhere((element) => !element!.isOk, orElse: () => null);
    if (firstKo != null) {
      return Result.ko(firstKo.error);
    } else {
      return Result.ok(builder(results.map((e) => e.result)));
    }
  }
}
