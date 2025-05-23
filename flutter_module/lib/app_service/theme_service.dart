import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/base/get_cupertino_controller.dart';
import 'package:flutter_module/enum/theme_type.dart';

class ThemeService extends GetxService {
  static ThemeService get find => Get.find<ThemeService>();

  final rxCurrentThemeType = ThemeType.light.obs;

  CupertinoThemeData get themeData {
    return rxCurrentThemeType.value.theme;
  }

  Color get indicatorColor {
    if (rxCurrentThemeType.value == ThemeType.light) {
      return Colors.blue;
    } else {
      return Colors.white;
    }
  }

  Color get labelColor {
    if (rxCurrentThemeType.value == ThemeType.light) {
      return Colors.blue;
    } else {
      return Colors.white;
    }
  }

  Color get unselectedLabelColor {
    if (rxCurrentThemeType.value == ThemeType.light) {
      return Colors.lightBlue;
    } else {
      return Colors.white60;
    }
  }

  void switchTheme(ThemeType type) async {
    final currentThemeType = await AccountService.find.getThemeSetting();
    if (currentThemeType == type) {
      return;
    }

    rxCurrentThemeType.value = type;
    saveThemeType(type);
    restartApp();
  }

  void saveThemeType(ThemeType type) {
    // 保存 主题设置
    AccountService.find.saveThemeSetting(type);
  }

  Future<ThemeType> getThemeType() async {
    // 获取主题设置
    final type = await AccountService.find.getThemeSetting();
    rxCurrentThemeType.value = type;
    return type;
  }

  // 重启应用的方法
  Future<void> restartApp() async {
    Get.find<GetMaterialController>().restartApp();
  }

  /// 通过GetCupertinoController更换主题颜色的思路
  void changeTheme(ThemeType type) async {
    final currentThemeType = await AccountService.find.getThemeSetting();
    if (currentThemeType == type) {
      return;
    }

    rxCurrentThemeType.value = type;
    Get.find<GetCupertinoController>().setCupertinoTheme(type.theme);
    AccountService.find.saveThemeSetting(type);
    Get.find<GetCupertinoController>().restartApp();
  }
}
