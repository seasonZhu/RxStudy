import 'package:flutter_module/base/class_name.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

import 'package:flutter_module/pages/my/controller/my_collect_controller.dart';
import 'package:flutter_module/pages/my/repository/my_collect_repository.dart';

class MyCollectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MyCollectRepository(),
    );
    Get.lazyPut(
      tag: className(MyCollectController),
      () => RefreshController(initialRefresh: true),
    );
    Get.lazyPut<int>(
      tag: className(MyCollectController),
      () => 0,
    );
    Get.lazyPut(
      () => MyCollectController(),
    );
  }
}
