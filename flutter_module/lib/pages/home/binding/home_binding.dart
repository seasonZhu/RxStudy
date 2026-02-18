import 'package:get/get.dart';
import 'package:flutter_module/base/class_name.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:flutter_module/pages/home/controller/home_controller.dart';
import 'package:flutter_module/pages/home/repository/home_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => HomeRepository(),
    );

    /// 需要通过tag来进行区分,避免RefreshController反复使用导致的内存泄露与崩溃
    /// 其实后来想想,其实把page与RefreshController在这里进行put,直接在onInit里面初始化反而逻辑更加简单
    Get.lazyPut(
      tag: className(HomeController),
      () => RefreshController(initialRefresh: true),
    );
    Get.lazyPut<int>(
      tag: className(HomeController),
      () => 1,
    );
    Get.lazyPut(
      () => HomeController(),
    );
  }
}
