import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/channel/channel.dart';
import 'package:flutter_module/entity/account_info_entity.dart';
import 'package:flutter_module/logger/logger.dart';
import 'package:flutter_module/pages/my/controller/my_controller.dart';

/// 通信随引擎初始化，不依赖欢迎页、主页或“我的”页面是否已创建。
class NativeChannelBridge {
  StreamSubscription<dynamic>? _events;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    methodChannel.setMethodCallHandler(_handleMethod);
    _events = eventChannel.receiveBroadcastStream().listen(
          (event) => logger.d('received event: $event'),
          onError: (Object error) => logger.w('原生事件通信失败：$error'),
        );
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await methodChannel.invokeMethod<void>('ready');
      } on MissingPluginException {
        // 独立 Flutter Runner 未接入原生桥接时仍可启动。
      }
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'userLocationUpdate':
        return '收到从Native传来的位置信息,这里是Flutter的返回的信息';
      case 'nativeLogin':
        final arguments = call.arguments;
        if (arguments is! String) {
          throw PlatformException(
              code: 'invalid_arguments', message: '登录信息必须是 JSON 字符串');
        }
        final AccountInfoEntity info;
        try {
          info = AccountInfoEntity.fromJson(
              jsonDecode(arguments) as Map<String, dynamic>);
        } catch (_) {
          throw PlatformException(
              code: 'invalid_arguments', message: '登录信息不是有效的账号数据');
        }
        await AccountService.find
            .save(info: info, isLogin: true, password: info.password ?? '');
        if (Get.isRegistered<MyController>()) {
          final controller = MyController.find;
          controller.isLogin.value = AccountService.find.isLogin;
          controller.rxUserInfo.value = AccountService.find.userInfo;
          await controller.autoLogin();
        }
        return '收到从Native传来的原生登录信息,Flutter侧执行登录逻辑成功';
      case 'nativeLogout':
        // 原生已完成退出，只同步本地状态，避免重复退出请求与回传循环。
        await AccountService.find.clear();
        if (Get.isRegistered<MyController>()) {
          final controller = MyController.find;
          controller.isLogin.value = false;
          controller.rxUserInfo.value = AccountService.find.userInfo;
        }
        return '收到从Native传来的原生登出信息,Flutter侧执行登出逻辑成功';
      default:
        throw MissingPluginException('未知的原生通信方法：${call.method}');
    }
  }

  Future<void> dispose() async {
    methodChannel.setMethodCallHandler(null);
    await _events?.cancel();
    _events = null;
    _started = false;
  }
}

final nativeChannelBridge = NativeChannelBridge();
