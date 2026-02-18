import 'package:flutter/material.dart';

/// 前景色（文本、按钮等）
const kAccentColor = Color(0xFFA3A4A4);

/// 背景色(view的背景与AppBar的背景)
const kBackgroundColor = Color(0xFF080810);

/// tabbar的背景色
const kTabbarColor = Color(0xFF1A1B1B);

extension Extension on Brightness {
  ThemeData get themeData {
    switch (this) {
      case Brightness.dark:
        return ThemeData(
          platform: TargetPlatform.iOS,
          // appBarTheme: AppBarTheme(
          //   shadowColor: Color(0xFF2F2F2F),
          //   centerTitle: true,
          //   iconTheme: IconThemeData(color: Colors.white),
          //   color: dsBackgroundColor,
          //   elevation: 0.1,
          // ),
          // scaffoldBackgroundColor: dsBackgroundColor,
          // bottomNavigationBarTheme: BottomNavigationBarThemeData(
          //   backgroundColor: dsTabbarColor,
          // ),
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,

          /// 点击的时候的高亮效果 如果想去掉这种波纹效果，可直接把它们设置为Colors.transparent
          highlightColor: Colors.transparent,

          /// 点击后不松手的扩散效果
          splashColor: Colors.transparent,
        );

      case Brightness.light:
        return ThemeData(
          platform: TargetPlatform.iOS,
          // appBarTheme: AppBarTheme(
          //   shadowColor: Colors.white10,
          //   centerTitle: true,
          //   iconTheme: IconThemeData(color: Colors.white),
          //   color: Colors.white10,
          //   elevation: 0.1,
          // ),
          // scaffoldBackgroundColor: Colors.white10,
          // bottomNavigationBarTheme: BottomNavigationBarThemeData(
          //   backgroundColor: Colors.white10,
          // ),
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity,

          /// 点击的时候的高亮效果 如果想去掉这种波纹效果，可直接把它们设置为Colors.transparent
          highlightColor: Colors.transparent,

          /// 点击后不松手的扩散效果
          splashColor: Colors.transparent,
        );
    }
  }

  Color get color {
    switch (this) {
      case Brightness.light:
        return Colors.black;
      case Brightness.dark:
        return Colors.white;
    }
  }
}

/// 纽曼风格
extension Neumorphism on Widget {
  addNeumorphism({
    double borderRadius = 10.0,
    Offset offset = const Offset(5, 5),
    double blurRadius = 10,
    Color topShadowColor = Colors.white60,
    Color bottomShadowColor = const Color(0x26234395),
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(
            offset: offset,
            blurRadius: blurRadius,
            color: bottomShadowColor,
          ),
          BoxShadow(
            offset: Offset(-offset.dx, -offset.dx),
            blurRadius: blurRadius,
            color: topShadowColor,
          ),
        ],
      ),
      child: this,
    );
  }
}
