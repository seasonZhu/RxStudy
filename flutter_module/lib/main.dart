import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'package:flutter_module/my_app.dart';
import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/example_app/stream_app.dart';
import 'package:flutter_module/example_app/get_x_app.dart';
import 'package:flutter_module/example_app/rx_dart_app.dart';
import 'package:flutter_module/example_app/h5_js_channel_app.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_module/app_service/theme_service.dart';

void main() => run();

run() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// 把初始化服务放到runApp之前
  final accountService = Get.put(AccountService());

  final themeService = Get.put(ThemeService());

  final isFirst = await accountService.getIsFirstLaunch();

  await themeService.getThemeType();

  /// 玩安卓App的进这个
  runApp(MyApp(isFirst: isFirst));

  /// 使用StreamController与StreamBuilder构建页面的进这个
  //runApp(StreamApp());

  /// 使用RxDart与StreamBuilder构建页面的进这个
  //runApp(RxDartApp());

  /// 使用GetX构建页面的进这个
  //runApp(GetXApp());

  /// Flutter与JS通信的进这个
  //runApp(H5JSChannelApp());

  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    const systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
