import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// 在创建GetCupertinoApp会默认创建GetMaterialController,但是GetMaterialController里面没有涉及到CupertinoThemeData的设置
/// 但是又无法对GetMaterialController新增属性,只能整个继承了然后再mixin
class GetCupertinoController extends GetMaterialController with UpdateCupertinoThemeData {}

mixin UpdateCupertinoThemeData on GetMaterialController {
  CupertinoThemeData? cupertinoTheme;

  CupertinoThemeData? darkCupertinoTheme;

  void setCupertinoTheme(CupertinoThemeData value) {
    if (darkCupertinoTheme == null) {
      cupertinoTheme = value;
    } else {
      if (value.brightness == Brightness.light) {
        cupertinoTheme = value;
      } else {
        darkCupertinoTheme = value;
      }
    }
    update();
  }
}