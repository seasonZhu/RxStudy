enum SuccessStatus {
  hasContent(2),
  empty(3);

  final int value;
  const SuccessStatus(this.value);

  @override
  String toString() => 'The $name value is $value';
}

enum ResponseStatus {
  loading(0),
  fail(1),
  successHasContent(2),
  successNoData(3);

  final int value;
  const ResponseStatus(this.value);

  @override
  String toString() => 'The $name value is $value';
}

/// 这是Dart新特性的例子
enum Water {
  frozen(0),
  lukewarm(40),
  boiling(100);

  final int temperature;
  const Water(this.temperature);

  @override
  String toString() => 'The $name water is $temperature';
}

/// 有关于枚举里面加泛型
enum Season<T extends Object> {
  spring("好"),
  summer(true),
  autumn(100),
  winter([]);

  final T value;
  const Season(this.value);
}

final season = Season.spring.value;
