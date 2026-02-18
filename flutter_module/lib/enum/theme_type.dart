import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

enum ThemeType {
  light,
  dark,
  blue,
  green,
  red;
}

extension Ext on ThemeType {
  String get title {
    switch (this) {
      case ThemeType.light:
        return "light".tr;
      case ThemeType.dark:
        return "dark".tr;
      case ThemeType.blue:
        return "blue".tr;
      case ThemeType.green:
        return "green".tr;
      case ThemeType.red:
        return "red".tr;
    }
  }

  CupertinoThemeData get theme {
    switch (this) {
      case ThemeType.light:
        return const CupertinoThemeData(
            primaryColor: Colors.blue,
            barBackgroundColor: Colors.white,
            brightness: Brightness.light);
      case ThemeType.dark:
        return const CupertinoThemeData(
          primaryColor: Colors.white,
          brightness: Brightness.dark,
          textTheme: CupertinoTextThemeData(primaryColor: Colors.white),
        );
      case ThemeType.blue:
        return const CupertinoThemeData(
            primaryColor: Colors.blue,
            barBackgroundColor: Colors.blue,
            textTheme: CupertinoTextThemeData(
              primaryColor: Colors.white,
              navTitleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            brightness: Brightness.light);
      case ThemeType.green:
        return const CupertinoThemeData(
            primaryColor: Colors.green,
            barBackgroundColor: Colors.green,
            textTheme: CupertinoTextThemeData(
              primaryColor: Colors.white,
              navTitleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            brightness: Brightness.light);
      case ThemeType.red:
        return const CupertinoThemeData(
            primaryColor: Colors.red,
            barBackgroundColor: Colors.red,
            textTheme: CupertinoTextThemeData(
              primaryColor: Colors.white,
              navTitleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            brightness: Brightness.light);
    }
  }
}
