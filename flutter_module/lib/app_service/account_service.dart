import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter_module/entity/account_info_entity.dart';
import 'package:flutter_module/enum/theme_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 这个类就像一个 "GetxController"，它共享相同的生命周期 （"onInit()"、"onReady()"、"onClose()"） 。 但里面没有 "逻辑"。它只是通知GetX的依赖注入系统，这个子类不能从内存中删除。
/// 所以这对保持你的 "服务 "总是可以被Get.find()获取到并保持运行是超级有用的。比如 ApiService，StorageService，CacheService。
class AccountService extends GetxService {
  final _kLastLoginUserName = "kLastLoginUserName";

  final _kLastLoginPassword = "kLastLoginPassword";

  final _kLastThemeSettingIndex = "kLastThemeSettingIndex";

  final _kAccountInfo = "kAccountInfo";

  final _kOpenDarkMode = "kOpenDarkMode";

  final _kIsFirstLaunch = "kIsFirstLaunch";

  final _kThemeSetting = "kThemeSetting";

  AccountInfoEntity? info;

  var isLogin = false;

  var userInfo = "等级 --  排名 --  积分 --";

  static AccountService get find => Get.find<AccountService>();

  Future<SharedPreferences> get userDefine async =>
      await SharedPreferences.getInstance();

  // 只读计算属性
  String get cookieHeaderValue {
    if (info?.username != null && info?.password != null) {
      return "loginUserName=${info?.username};loginUserPassword=${info?.password}";
    } else {
      return "";
    }
  }

  Future<void> save(
      {required AccountInfoEntity info,
      required bool isLogin,
      required String password}) async {
    this.info = info;
    this.isLogin = true;
    this.info?.password = password;

    final userDefine = await this.userDefine;
    userDefine.setString(_kLastLoginUserName, info.username ?? "");
    userDefine.setString(_kLastLoginPassword, password);
    // 本来想尝试保存一个字典的,结果没这个方法,只有List<String>,但是我可以将Map转为String在存呀
    final infoJsonString = json.encode(info.toJson());
    userDefine.setString(_kAccountInfo, infoJsonString);
  }

  Future<bool> saveLastThemeSettingIndex(int index) async {
    final userDefine = await this.userDefine;
    return userDefine.setInt(_kLastThemeSettingIndex, index);
  }

  Future<bool> saveOpenDarkMode(bool isOpenDarkMode) async {
    final userDefine = await this.userDefine;
    return userDefine.setBool(_kOpenDarkMode, isOpenDarkMode);
  }

  Future<bool> saveNotFirstLaunch() async {
    final userDefine = await this.userDefine;
    return userDefine.setBool(_kIsFirstLaunch, false);
  }

  Future<bool> saveThemeSetting(ThemeType type) async {
    final userDefine = await this.userDefine;
    return userDefine.setInt(_kThemeSetting, type.index);
  }

  Future<String> getLastLoginUserName() async {
    final userDefine = await this.userDefine;
    return userDefine.getString(_kLastLoginUserName) ?? "";
  }

  Future<String> getLastAccountInfo() async {
    final userDefine = await this.userDefine;
    return userDefine.getString(_kAccountInfo) ?? "";
  }

  Future<int> getLastThemeSettingIndex() async {
    final userDefine = await this.userDefine;
    return userDefine.getInt(_kLastThemeSettingIndex) ?? 0;
  }

  Future<String> getLastLoginPassword() async {
    final userDefine = await this.userDefine;
    return userDefine.getString(_kLastLoginPassword) ?? "";
  }

  Future<bool> getIsOpenDarkMode() async {
    final userDefine = await this.userDefine;
    return userDefine.getBool(_kOpenDarkMode) ?? false;
  }

  Future<bool> getIsFirstLaunch() async {
    final userDefine = await this.userDefine;
    return userDefine.getBool(_kIsFirstLaunch) ?? true;
  }

  Future<ThemeType> getThemeSetting() async {
    final userDefine = await this.userDefine;
    final index = userDefine.getInt(_kThemeSetting) ?? 0;
    return ThemeType.values[index];
  }

  Future<void> clear() async {
    info = null;
    userInfo = "等级 --  排名 --  积分 --";
    isLogin = false;
    final userDefine = await this.userDefine;
    userDefine.remove(_kLastLoginUserName);
    userDefine.remove(_kLastLoginPassword);
  }
}
