import 'package:get/get.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/enum/response_status.dart';
import 'package:flutter_module/routes/routes.dart';

abstract class BaseController extends GetxController
    implements IRetry, IEmptyTap {
  ResponseStatus status = ResponseStatus.loading;
}

/// 要不要with是个问题
mixin ResponseStatusMixin on GetxController {
  ResponseStatus status = ResponseStatus.loading;
}

/// 目前这个玩安卓版本的设计是如果用户是游客,就直接屏蔽功能
/// 这里考虑的是如果所有功能都是开放的,那么点击事件最后都会传到Controller层,那么控制器层就需要用一个方法做统一拦截
/// 这里考虑用的mixin的方式,这样的好处的是,有些页面根本就不需要检查是否登录,也就减少了继承的成本
/// 但是用mixin的问题是,很多页面又都需要写with
/// 先with然后再extends?
/// 本质上GetMiddleware的中间件已经做了这个事情,详细看LoginMiddleware,但是如何去拦截点击事情还没想好
mixin CheckIsLoginMixin on BaseController {
  bool checkIsLogin() {
    if (!AccountService.find.isLogin) {
      Get.toNamed(Routes.login);
    }

    return AccountService.find.isLogin;
  }
}
