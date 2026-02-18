import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:flutter_module/app_service/theme_service.dart';
import 'package:flutter_module/enum/main_tag_type.dart';
import 'package:flutter_module/pages/main/controller/main_controller.dart';
import 'package:flutter_module/enum/theme_type.dart';

class MainPage extends GetView<MainController> {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      builder: ((controller) {
        return CupertinoTabScaffold(
          tabBuilder: (context, index) {
            final type = MainTagType.values[index];
            return CupertinoTabView(builder: (context) {
              return type.page;
            });
          },
          tabBar: CupertinoTabBar(
            items: MainTagTypeExt.items,

            /// 这个地方目前这样写无法感知到变化,于是我使用了全局的GetMaterialController这个库来进行App的重启
            backgroundColor:
                ThemeService.find.rxCurrentThemeType.value == ThemeType.dark
                    ? Colors.black
                    : Colors.white,
            currentIndex: controller.selectedIndex, //默认选中的 index
            onTap: controller.onItemTapped,
          ),
        );
      }),
    );
  }
}
