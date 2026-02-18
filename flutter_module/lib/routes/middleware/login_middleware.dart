import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/routes/routes.dart';

class LoginMiddleware extends GetMiddleware {
  /// 当需要执行路由的重定向时，就可以调用此函数，比如使用它实现强制登录逻辑，即没有登录时跳转登录逻辑。
  @override
  RouteSettings? redirect(String? route) {
    return AccountService.find.isLogin
        ? super.redirect(route)
        : const RouteSettings(name: Routes.login);
  }
}
