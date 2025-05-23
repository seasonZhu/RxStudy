import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:flutter_module/extension/theme_data_extension.dart';
import 'package:flutter_module/logger/logger.dart';
import 'package:flutter_module/routes/getx_router_observer.dart';
import 'package:flutter_module/routes/history_router_observer.dart';
import 'package:flutter_module/routes/routes.dart';
import 'package:flutter_module/app_service/theme_service.dart';
import 'package:flutter_module/i18n/localized_strings.dart';

class MyApp extends StatelessWidget {
  final bool isFirst;

  const MyApp({Key? key, required this.isFirst}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetCupertinoApp(
        title: 'GetX Study',
        navigatorObservers: [getXRouterObserver, historyRouterObserver],
        unknownRoute: Routes.unknownPage,

        /// 通过使用initialRoute来保证绑定的操作
        initialRoute: isFirst ? Routes.welcome : Routes.splash,
        getPages: Routes.routePage,
        onGenerateRoute: (settings) {
          logger.d(settings.name);
          return null;
        },

        /// 使用toast
        builder: EasyLoading.init(),
        theme: ThemeService.find.themeData, //_getCupertinoCurrentTheme(),
        translations: LocalizedStrings(),
        locale: Get.deviceLocale, //不加这个就不知道当前要用什么locale下的语言, i18n就会失败
        fallbackLocale: const Locale("en", "US"),
      );
    });
  }

  /// App运行过程中,如果在iOS的设置中更改了亮度模式,还是无法实时进行更改,只能下次运行的时候才能体现变化,体验不好
  ThemeData _getMaterialCurrentTheme() {
    return WidgetsBinding
        .instance.platformDispatcher.platformBrightness.themeData;
    //return View.of(context).platformDispatcher.platformBrightness.themeData;
    //return SchedulerBinding.instance.window.platformBrightness.themeData;
  }

  CupertinoThemeData _getCupertinoCurrentTheme() {
    return const CupertinoThemeData(
        primaryColor: Colors.blue,
        barBackgroundColor: Colors.white,
        brightness: Brightness.light);
  }

  /// 悼念模式
  /// 将这个包裹在GetCupertinoApp外层即可,具体颜色一把使用grey
  Widget _changeColorModel({required Color color, required Widget widget}) {
    return ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.color), child: widget);
  }
}
