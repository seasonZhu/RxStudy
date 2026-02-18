import 'package:get/get.dart';

import 'package:flutter_module/pages/my/controller/my_controller.dart';
import 'package:flutter_module/pages/my/repository/my_repository.dart';

class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      fenix: true,
      () => MyRepository(),
    );
    Get.lazyPut(
      () => MyController(),
    );
  }
}
