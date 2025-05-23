import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_module/app_service/theme_service.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/pages/web/controller/web_controller.dart';
import 'package:marqueer/marqueer.dart';

import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/extension/string_extension.dart';

class WebPage extends GetView<WebController> {
  final themeService = ThemeService.find;

  WebPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// 平台判断
    IWebLoadInfo webLoadInfo = Get.arguments;
    final isCollect = controller.isCollect(webLoadInfo).obs;
    final notShowCollectIcon = Get.parameters['notShowCollectIcon'];
    final className = Get.parameters['className'];
    controller.className = className;
    bool isShowCollectIcon;
    if (notShowCollectIcon == "true") {
      isShowCollectIcon = false;
    } else {
      isShowCollectIcon = webLoadInfo.id != null && AccountService.find.isLogin;
    }

    controller.flutterWebViewSetting(webLoadInfo);

    return PopScope(
      canPop: false, // 默认不允许弹出
      onPopInvoked: (bool didPop) async {
        // 这里可以插入你的逻辑,比如确认是否退出,对iOS没有效果,不知道对Android是否有效
        controller.onBackAction();
      },
      child: Obx(
        () => CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            automaticallyImplyLeading: controller.canGoBack.value,
            leading: CupertinoNavigationBarBackButton(
              onPressed: () async {
                controller.onBackAction();
              },
            ),
            middle: _title(webLoadInfo),
            trailing: SizedBox(
              width: 100,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Visibility(
                  visible: webLoadInfo.id != null,
                  child: IconButton(
                    icon: const Icon(CupertinoIcons.share),
                    onPressed: () {
                      if (webLoadInfo.link != null) {
                        Share.share(webLoadInfo.link!);
                      }
                    },
                  ),
                ),
                Visibility(
                  visible: isShowCollectIcon,
                  child: IconButton(
                    icon: Obx(
                      () {
                        final icon = isCollect.value
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart;
                        return Icon(icon);
                      },
                    ),
                    onPressed: () async {
                      isCollect.value =
                          await controller.collectOrUnCollectAction(
                              webLoadInfo: webLoadInfo,
                              isCollect: isCollect.value);
                    },
                  ),
                ),
              ]),
            ),
          ),
          // We're using a Builder here so we have a context that is below the Scaffold
          // to allow calling Scaffold.of(context) so we can show a snackbar.
          child: SafeArea(
            child: Builder(builder: (BuildContext context) {
              /// 这里没有使用下拉刷新组件,是因为SmartRefresh+WebViewWidget会导致底部显示异常
              return WebViewWidget(
                  controller: controller.webViewController,
                  gestureRecognizers: Set()
                    ..add(
                      Factory<OneSequenceGestureRecognizer>(
                        () => HorizontalDragGestureRecognizer()
                          ..onStart = (DragStartDetails details) {
                            // 处理拖动开始的逻辑
                            print("处理拖动开始的逻辑");
                          }
                          ..onUpdate = (DragUpdateDetails details) {
                            // 处理拖动更新的逻辑
                            print("处理拖动更新的逻辑");
                          }
                          ..onEnd = (DragEndDetails details) {
                            // 处理拖动结束的逻辑
                            print("处理拖动结束的逻辑");
                          },
                      ),
                    )
                  // ..add(
                  //   Factory<OneSequenceGestureRecognizer>(
                  //     () => LongPressGestureRecognizer()
                  //       ..onLongPress = () {
                  //         print('长按');
                  //       },
                  //   ),
                  // ),
                  );
            }),
          ),
        ),
      ),
    );
  }

  Widget _title(IWebLoadInfo webLoadInfo) {
    if (webLoadInfo.id != null) {
      return SizedBox(
        height: 44,
        child: Marqueer(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              webLoadInfo.title.toString().replaceHtmlElement,
              style: themeService.themeData.textTheme.navTitleTextStyle,
            ),
          ),
        ),
      );
    } else {
      return Text(
        webLoadInfo.title.toString(),
      );
    }
  }
}
