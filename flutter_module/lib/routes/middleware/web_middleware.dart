import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

/// 这地方感觉特别像一个页面的生命周期
class WebMiddleware extends GetMiddleware {
  /// 页面消失的时候操作
  @override
  void onPageDispose() {
    super.onPageDispose();
    EasyLoading.dismiss(animation: false);
  }

  /// 有时候，我们需要在页面创建之前调用某个额函数，比如可以使用它来更改页面的某些内容或为其提供新页面。
  @override
  GetPage? onPageCalled(GetPage? page) {
    // TODO: implement onPageCalled
    return super.onPageCalled(page);
  }

  /// 此函数将在初始化绑定之前被调用。在这个函数中，我们可以更改页面的绑定。
  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    // TODO: implement onBindingsStart
    return super.onBindingsStart(bindings);
  }

  /// 此函数将在绑定初始化之后被调用。在这个函数中，我们可以在创建绑定之后和创建页面小部件之前执行一些操作
  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    // TODO: implement onPageBuildStart
    return super.onPageBuildStart(page);
  }

  /// 创建小部件之后执行
  @override
  Widget onPageBuilt(Widget page) {
    // TODO: implement onPageBuilt
    return super.onPageBuilt(page);
  }
}