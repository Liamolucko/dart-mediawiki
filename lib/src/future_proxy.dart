import 'dart:async';

import 'package:meta/meta.dart';

/// Implements [Future] as a proxy for protected property [future].
/// Note that you still need to add `implements Future<T>` for Dart Analyze
/// to consider your class awaitable.
mixin FutureProxy<T> implements Future<T> {
  @protected
  Future<T> future;

  @override
  Stream<T> asStream() => future.asStream();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error) test}) =>
      future.catchError(onError, test: test);

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue,
          {Function onError}) =>
      future.then(onValue, onError: onError);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function() onTimeout}) =>
      future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(FutureOr Function() action) =>
      future.whenComplete(action);
}
