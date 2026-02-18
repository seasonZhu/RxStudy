/*

/// 已经通过AccountService类进行了封装,所以这个类可以不使用了
import 'dart:convert';

import 'package:flutter_module/entity/account_info_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountManager {
  /// 以下字符串常量私有化比较好

  final kLastLoginUserName = "kLastLoginUserName";

  final kLastLoginPassword = "kLastLoginPassword";

  final kLastThemeSettingIndex = "kLastThemeSettingIndex";

  final kAccountInfo = "kAccountInfo";

  final kOpenDarkMode = "kOpenDarkMode";

  final kIsFirstLaunch = "kIsFirstLaunch";

  AccountInfoEntity? info;

  var isLogin = false;

  var userInfo = "等级 --  排名 --  积分 --";

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
    userDefine.setString(kLastLoginUserName, info.username ?? "");
    userDefine.setString(kLastLoginPassword, password);
    // 本来想尝试保存一个字典的,结果没这个方法,只有List<String>,但是我可以将Map转为String在存呀
    final infoJsonString = json.encode(info.toJson());
    userDefine.setString(kAccountInfo, infoJsonString);
  }

  Future<bool> saveLastThemeSettingIndex(int index) async {
    final userDefine = await this.userDefine;
    return userDefine.setInt(kLastThemeSettingIndex, index);
  }

  Future<bool> saveOpenDarkMode(bool isOpenDarkMode) async {
    final userDefine = await this.userDefine;
    return userDefine.setBool(kOpenDarkMode, isOpenDarkMode);
  }

  Future<bool> saveNotFirstLaunch() async {
    final userDefine = await this.userDefine;
    return userDefine.setBool(kIsFirstLaunch, false);
  }

  Future<String> getLastLoginUserName() async {
    final userDefine = await this.userDefine;
    return userDefine.getString(kLastLoginUserName) ?? "";
  }

  Future<String> getLastAccountInfo() async {
    final userDefine = await this.userDefine;
    return userDefine.getString(kAccountInfo) ?? "";
  }

  Future<int> getLastThemeSettingIndex() async {
    final userDefine = await this.userDefine;
    return userDefine.getInt(kLastThemeSettingIndex) ?? 0;
  }

  Future<String> getLastLoginPassword() async {
    final userDefine = await this.userDefine;
    return userDefine.getString(kLastLoginPassword) ?? "";
  }

  Future<bool> getIsOpenDarkMode() async {
    final userDefine = await this.userDefine;
    return userDefine.getBool(kOpenDarkMode) ?? false;
  }

  Future<bool> getIsFirstLaunch() async {
    final userDefine = await this.userDefine;
    return userDefine.getBool(kIsFirstLaunch) ?? true;
  }

  Future<void> clear() async {
    info = null;
    userInfo = "等级 --  排名 --  积分 --";
    isLogin = false;
    final userDefine = await this.userDefine;
    userDefine.remove(kLastLoginUserName);
    userDefine.remove(kLastLoginPassword);
  }

  // 单例模式写法
  // 类名._() 是将初始化方法私有化
  AccountManager._();

  /// 类Swift的单例写法,这种写法的劣势是无法进行销毁,所以才有了clear方法
  static final shared = AccountManager._();

  /// 普通的单例写法
  static AccountManager? _instance;

  static AccountManager get instance => _instance ??= AccountManager._();

  /// GetX的单例写法
  factory AccountManager() => _instance ??= AccountManager._();

  /// 销毁单例
  static void destroyInstance() => _instance = null;
}
*/
