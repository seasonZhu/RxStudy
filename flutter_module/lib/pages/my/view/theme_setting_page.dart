import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_module/enum/theme_type.dart';
import 'package:flutter_module/app_service/theme_service.dart';

class ThemeSettingPage extends StatelessWidget {
  const ThemeSettingPage({Key? key}) : super(key: key);

  final dataSource = ThemeType.values;

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.find;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("theme_setting".tr),
      ),
      child: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(dataSource[index].title),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  themeService.switchTheme(dataSource[index]);

                  /// 尝试使用国际化
                  if (index == 0) {
                    var locale = const Locale('en', 'US');
                    Get.updateLocale(locale);
                  } else if (index == 1) {
                    var locale = const Locale('zh', 'CN');
                    Get.updateLocale(locale);
                  } else if (index == 2) {
                    var locale = const Locale('fr', 'FR');
                    Get.updateLocale(locale);
                  } else {}
                });
          },
          separatorBuilder: (context, index) {
            return const Divider(
              indent: 15,
              height: 0.5,
            );
          },
          itemCount: dataSource.length),
    );
  }
}
