import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:flutter_module/pages/web/controller/web_controller.dart';
import 'package:flutter_module/pages/web/repository/web_repository.dart';
import 'package:flutter_module/base/class_name.dart';

class WebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => WebRepository(),
    );
    Get.lazyPut(
      () => WebController(),
    );
    Get.lazyPut(
      tag: className(WebController),
      () => RefreshController(initialRefresh: false),
    );
  }
}
