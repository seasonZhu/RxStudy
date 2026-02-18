import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_module/generated/assets.dart';

import 'package:flutter_module/routes/routes.dart';
import 'package:flutter_module/pages/common/countdown_circle.dart';

/// 模拟的一个广告页面
class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            //设置背景图片
            image: DecorationImage(
              image: AssetImage(Assets.assetsImagesLaunchImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: 88,
          child: CountdownCircle(
            finished: (byUserClick) {
              Get.offAllNamed(Routes.main);
            },
          ),
        ),
      ],
    );
  }
}
