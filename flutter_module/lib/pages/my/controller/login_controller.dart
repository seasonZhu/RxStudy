import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/base/base_request_controller.dart';
import 'package:flutter_module/base/resign_first_responder.dart';
import 'package:flutter_module/entity/account_info_entity.dart';
import 'package:flutter_module/pages/my/controller/get_user_info_mixin.dart';
import 'package:flutter_module/pages/my/repository/my_repository.dart';
import 'package:flutter_module/logger/logger.dart';

class LoginController
    extends BaseRequestController<MyRepository, AccountInfoEntity>
    with GetUserInfoMixin {
  final userNameTextFiledController = TextEditingController(text: "");

  final passwordTextFiledController = TextEditingController(text: "");

  final userNameIsNotEmpty = false.obs;

  final passwordIsNotEmpty = false.obs;

  final obscureText = true.obs;

  final userNameFocusNode = FocusNode();

  final passwordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    logger.d("onInit");
  }

  void login({required String username, required String password}) async {
    ResignFirstResponder.unfocus();
    final response =
        await request.login(username: username, password: password);

    String message;
    if (response.isSuccess == true && response.data != null) {
      await AccountService.find
          .save(info: response.data!, isLogin: true, password: password);
      await getUserCoinInfo();
      message = "登录成功";

      final arguments = await AccountService.find.getLastAccountInfo();
      AccountService.find.flutterCallbackLoginMethod(arguments);
    } else {
      message = "登录失败";
    }

    /// 在这里可以跳转
    // Get.back();
    // return;
    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          /// 在这里不能跳转,目前还没找到原因
          // Get.back();
          if (response.isSuccess) {
            final params = {
              "isLogin": AccountService.find.isLogin,
              "userInfo": userInfo,
            };
            navigator?.pop(params);
          }
          // navigator?.popUntil(
          //   (route) => route.settings.name == Routes.main,
          // );
        }
      },
    );
  }

  void userNameTextFieldOnSubmitted(BuildContext context) {
    userNameFocusNode.unfocus();
    FocusScope.of(context).requestFocus(passwordFocusNode);
  }

  @override
  void onClose() {
    super.onClose();
    userNameFocusNode.dispose();
    passwordFocusNode.dispose();
  }
}
