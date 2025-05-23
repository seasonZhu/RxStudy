import 'package:get/get.dart';

import 'package:flutter_module/pages/home/repository/hot_key_repository.dart';
import 'package:flutter_module/pages/home/controller/hot_key_controller.dart';

class HotKeyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => HotKeyRepository(),
    );
    Get.lazyPut(
      () => HotKeyController(),
    );
  }
}
