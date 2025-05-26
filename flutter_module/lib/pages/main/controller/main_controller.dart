import 'dart:convert';

import 'package:flutter_module/pages/my/controller/my_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/entity/account_info_entity.dart';
import 'package:flutter_module/channel/channel.dart';
import 'package:flutter_module/logger/logger.dart';

class MainController extends GetxController {
  var selectedIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _listenMethodChannel();
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    update();

    //getFindTest();
  }

  void getFindTest() {
    /// Get.putAsyn使用的时候要稍微注意,避免先find后put
    final prefs = Get.find<SharedPreferences>();
    int? count = prefs.getInt('counter');
    logger.d(count);
  }

  void _listenMethodChannel() {
    methodChannel.setMethodCallHandler((call) {
      final method = call.method;
      final jsonString = call.arguments;
      logger.d("从Native侧传递过来的方法: $method");
      logger.d("从Native侧传递过来的参数: $jsonString");

      switch (method) {
        case "userLocationUpdate":
          return Future.value("收到从Native传来的位置信息,这里是Flutter的返回的信息");
        case "nativeLogin":
          Map<String, dynamic> map = jsonDecode(jsonString);
          final info = AccountInfoEntity.fromJson(map);
          AccountService.find
              .save(info: info, isLogin: true, password: info.password ?? "");
          MyController.find.autoLogin();
          return Future.value("收到从Native传来的原生登录信息,Flutter侧执行登录逻辑成功");
        case "nativeLogout":
          MyController.find.logout().then((result) {
            MyController.find.rxUserInfo.value = AccountService.find.userInfo;
            MyController.find.isLogin.value = result;
          });
          return Future.value("收到从Native传来的原生登出信息,Flutter侧执行登出逻辑成功");
        default:
          logger.w("未知的方法: $method");
          return Future.value("未知的方法: $method");
      }
    });
  }
}
