import 'package:get/get.dart';
import 'package:flutter_module/pages/my/controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LoginController(),
      // fenix: true,
    );
  }
}
