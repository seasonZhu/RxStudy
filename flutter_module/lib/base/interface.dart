import 'package:get/get.dart';

abstract class IRepository {}

/// 重试机制
abstract class IRetry {
  /// 这里写不写方法的实现好像并不影响代码编译与逻辑
  void retry();
}

/// 点击空白机制
abstract class IEmptyTap {
  /// 这里写不写方法的实现好像并不影响代码编译与逻辑
  void emptyTap();
}

/// 跳转Web的模型基类
abstract class IWebLoadInfo {
  int? id;
  int? originId;
  String? title;
  String? link;
}

/// 以下代码没有使用,是思考

abstract class IRequestController extends GetxController {}

/// 危险,不要定义这个类
/// typedef GetPage<T> = GetView<T>;

///  下面这个类在使用上没有意义
/*
abstract class IClassName {
  static String? className;

  /// 协议的类方法必须要进行实现,否则就会报错
  // static String? Some();

  // String some();
}
*/

