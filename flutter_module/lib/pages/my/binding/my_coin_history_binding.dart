import 'package:flutter_module/base/class_name.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

import 'package:flutter_module/pages/my/controller/my_coin_history_controller.dart';
import 'package:flutter_module/pages/my/repository/my_coin_history_repository.dart';

class MyCoinHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MyCoinHistoryRepository(),
    );

    /// 需要通过tag来进行区分,避免RefreshController反复使用导致的内存泄露与崩溃
    Get.lazyPut(
      tag: className(MyCoinHistoryController),
      () => RefreshController(initialRefresh: true),
    );
    Get.lazyPut<int>(
      tag: className(MyCoinHistoryController),
      () => 1,
    );
    Get.lazyPut(
      () => MyCoinHistoryController(),
    );
  }
}
