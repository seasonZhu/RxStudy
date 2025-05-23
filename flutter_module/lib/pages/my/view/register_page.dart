import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_module/base/resign_first_view.dart';
import 'package:flutter_module/pages/my/controller/register_controller.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResignFirstView(
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text("注册"),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoTextField(
                          controller: controller.userNameTextFiledController,
                          focusNode: controller.userNameFocusNode,
                          placeholder: "手机号",
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => controller
                              .userNameIsNotEmpty.value = value.isNotEmpty,
                          onSubmitted: (_) =>
                              controller.userNameTextFieldOnSubmitted(context),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: InkWell(
                          child: const Icon(Icons.clear),
                          onTap: () {
                            controller.userNameTextFiledController.text = "";
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Obx(
                          () => CupertinoTextField(
                            enabled: controller.userNameIsNotEmpty.value,
                            controller: controller.passwordTextFiledController,
                            focusNode: controller.passwordFocusNode,
                            placeholder: "密码",
                            textInputAction: TextInputAction.next,
                            obscureText: controller.obscureText.value,
                            onChanged: (value) =>
                                controller.password.value = value,
                            onSubmitted: (_) => controller
                                .passwordTextFieldOnSubmitted(context),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        width: 38,
                        child: Obx(
                          () => InkWell(
                            child: controller.obscureText.value
                                ? const Icon(Icons.remove_red_eye)
                                : const Icon(Icons.security),
                            onTap: () {
                              final value = controller.obscureText.value;
                              controller.obscureText.value = !value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Obx(
                          () => CupertinoTextField(
                            enabled: controller.userNameIsNotEmpty.value &&
                                controller.password.value.isNotEmpty,
                            controller:
                                controller.rePasswordTextFiledController,
                            focusNode: controller.rePasswordFocusNode,
                            placeholder: "确认密码",
                            textInputAction: TextInputAction.done,
                            obscureText: controller.reObscureText.value,
                            onChanged: (value) =>
                                controller.rePassword.value = value,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        width: 38,
                        child: Obx(
                          () => InkWell(
                            child: controller.reObscureText.value
                                ? const Icon(Icons.remove_red_eye)
                                : const Icon(Icons.security),
                            onTap: () {
                              final value = controller.reObscureText.value;
                              controller.reObscureText.value = !value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 15, right: 15),
                    child: SizedBox(
                      /// 这个地方可以写宽一点 会被Padding卡住
                      width: double.infinity,
                      height: 44,
                      child: Obx(
                        () => Visibility(
                          visible: controller.isShowRegisterButton,
                          child: TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                              ),
                              child: const Text(
                                "注册",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              onPressed: () {
                                controller.register(
                                  username: controller
                                      .userNameTextFiledController.text,
                                  password: controller
                                      .passwordTextFiledController.text,
                                  rePassword: controller
                                      .rePasswordTextFiledController.text,
                                );
                              }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
