/*
import 'dart:async';

/// https://juejin.cn/post/7372503361361068082
/// This requires the 'records' language feature to be enabled.
/// Try updating your pubspec.yaml to set the minimum SDK constraint to 3.0.0 or higher, and running 'pub get'.
extension FutureZipX<T> on Future<T> {
  Future<(T, T2)> zipWith<T2>(Future<T2> future2) async {
    late T result1;
    late T2 result2;
    await Future.wait([
      then((it) => result1 = it),
      future2.then((it) => result2 = it)
    ]);
    return (result1, result2);
  }
}

final (name, year, married) = await (
Future.value("andrew"),
Future.value(1984),
Future.value(false),
).wait;

final (name, year) = await Future.value("andrew")
    .zipWith(Future.value(1984));
*/