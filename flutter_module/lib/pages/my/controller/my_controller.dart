import 'package:get/get.dart';
import 'package:flutter/services.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/base/base_request_controller.dart';
import 'package:flutter_module/entity/account_info_entity.dart';
import 'package:flutter_module/pages/my/controller/get_user_info_mixin.dart';
import 'package:flutter_module/pages/my/repository/my_repository.dart';
import 'package:flutter_module/logger/logger.dart';
import 'package:flutter_module/channel/channel.dart';

class MyController
    extends BaseRequestController<MyRepository, AccountInfoEntity>
    with GetUserInfoMixin {
  /*
     为了避免这种问题，_observable_的第一次变化将总是触发一个事件，即使它包含相同的.value。
     如果你想删除这种行为，你可以使用： isLogin.firstRebuild = false;。
     */
  final isLogin = AccountService.find.isLogin.obs;

  final rxUserInfo = AccountService.find.userInfo.obs;

  static MyController get find => Get.find<MyController>();

  @override
  void onInit() {
    super.onInit();
    logger.d("onInit");
  }

  Future<bool> logout() async {
    final response = await request.logout();
    String message;
    if (response.isSuccess) {
      message = "登出成功";
      AccountService.find.clear();
      flutterCallbackLogoutMethod();
    } else {
      message = "登出失败";
    }
    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
    );
    return AccountService.find.isLogin;
  }

  Future<void> autoLogin() async {
    final username = await AccountService.find.getLastLoginUserName();
    final password = await AccountService.find.getLastLoginPassword();

    if (username.isNotEmpty && password.isNotEmpty) {
      final response =
          await request.login(username: username, password: password);

      String message;
      if (response.isSuccess == true && response.data != null) {
        await AccountService.find
            .save(info: response.data!, isLogin: true, password: password);
        message = "自动登录成功";

        await getUserCoinInfo();

        isLogin.value = AccountService.find.isLogin;
        rxUserInfo.value = AccountService.find.userInfo;
      } else {
        message = "自动登录失败";
      }
      Get.snackbar(
        "",
        message,
        duration: const Duration(seconds: 1),
      );
    }
  }

  Future<void> flutterCallbackPopMethod() async {
    try {
      // 约定好返回参数的类型,便于进行交互
      logger.d("flutterCallbackPopMethod");
      var _ = await methodChannel.invokeMethod('pop', null);
    } on PlatformException catch (e) {
      //抛出异常
      logger.d(e.toString());
    }
  }

  Future<void> flutterCallbackLogoutMethod() async {
    try {
      // 约定好返回参数的类型,便于进行交互
      logger.d("flutterCallbackLogoutMethod");
      var _ = await methodChannel.invokeMethod('logout', null);
    } on PlatformException catch (e) {
      //抛出异常
      logger.d(e.toString());
    }
  }
}
