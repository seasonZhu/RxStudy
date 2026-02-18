import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/base/resign_first_responder.dart';
import 'package:flutter_module/pages/my/controller/login_controller.dart';
import 'package:flutter_module/logger/logger.dart';

class RegisterController extends LoginController {
  final rePasswordTextFiledController = TextEditingController(text: "");

  final password = "".obs;

  final rePassword = "".obs;

  final reObscureText = true.obs;

  final rePasswordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    logger.d("onInit");
  }

  void register(
      {required String username,
      required String password,
      required String rePassword}) async {
    ResignFirstResponder.unfocus();
    final response = await request.register(
        username: username, password: password, rePassword: rePassword);

    String message;
    if (response.isSuccess == true && response.data != null) {
      await AccountService.find
          .save(info: response.data!, isLogin: true, password: password);
      await getUserCoinInfo();
      message = "注册成功";
      
      final arguments = await AccountService.find.getLastAccountInfo();
      AccountService.find.flutterCallbackLoginMethod(arguments);
    } else {
      message = "注册失败";
    }
    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          if (response.isSuccess) {
            Future.delayed(
              const Duration(seconds: 0),
              () => navigator?.pop(AccountService.find.isLogin),
            );
          }
        }
      },
    );
  }

  void passwordTextFieldOnSubmitted(BuildContext context) {
    passwordFocusNode.unfocus();
    FocusScope.of(context).requestFocus(rePasswordFocusNode);
  }

  @override
  void onClose() {
    super.onClose();
    rePasswordFocusNode.dispose();
  }

  bool get isShowRegisterButton =>
      (userNameIsNotEmpty.value &&
          password.value.isNotEmpty &&
          rePassword.value.isNotEmpty) &&
      (password == rePassword);
}
