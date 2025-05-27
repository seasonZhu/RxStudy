import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/enum/my.dart' as my;
import 'package:flutter_module/pages/my/controller/my_controller.dart';
import 'package:flutter_module/routes/routes.dart';

class MyPage extends GetView<MyController> {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("我的"),
      ),
      child: Obx(
        () {
          final dataSource = controller.isLogin.value
              ? my.Extension.userDataSource
              : my.Extension.visitorDataSource;
          final icon = controller.isLogin.value ? Icons.android : Icons.person;

          return ListView.separated(
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 66,
                          height: 66,
                          child: Icon(icon),
                        ),
                        Text(controller.rxUserInfo.value),
                      ],
                    ),
                  );
                } else {
                  final model = dataSource[index];
                  return ListTile(
                    leading: Icon(model.icon),
                    title: Text(model.title),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      if (model == my.My.login) {
                        final result = await Get.toNamed(Routes.login);

                        if (result != null) {
                          final map = result as Map<String, dynamic>;
                          controller.isLogin.value = map["isLogin"];
                          controller.rxUserInfo.value = map["userInfo"];
                        }
                      } else if (model == my.My.logout) {
                        showCupertinoDialog(
                          context: context,
                          builder: ((context) {
                            return CupertinoAlertDialog(
                              title: const Text("提示"),
                              content: const Text("是否登出?"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text(
                                    "取消",
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  onPressed: () => Get.back(), //关闭对话框
                                ),
                                TextButton(
                                  child: const Text(
                                    "确定",
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  onPressed: () async {
                                    Get.back();
                                    final result = await controller.logout();
                                    controller.rxUserInfo.value =
                                        AccountService.find.userInfo;
                                    controller.isLogin.value = result;
                                  },
                                ),
                              ],
                            );
                          }),
                        );
                      } else if (model == my.My.toNative) {
                        controller.flutterCallbackPopMethod();
                      } else {
                        if (model.entity != null) {
                          Get.toNamed(model.path, arguments: model.entity);
                        } else {
                          Get.toNamed(model.path);
                        }
                      }
                    },
                  );
                }
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  indent: 15,
                  height: 0.5,
                );
              },
              itemCount: dataSource.length);
        },
      ),
    );
  }
}
