import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/generated/assets.dart';
import 'package:flutter_module/routes/routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const ClampingScrollPhysics(),
        children: [
          _welcomeView(Assets.assetsImagesWelcome1, false),
          _welcomeView(Assets.assetsImagesWelcome2, true),
        ],
      ),
    );
  }

  Widget _welcomeView(String imageName, bool visible) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            //设置背景图片
            image: DecorationImage(
              image: AssetImage(imageName),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Visibility(
          visible: visible,
          child: Positioned(
            left: 20,
            right: 20,
            bottom: 44,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
              ),
              child: const Text("点击进入"),
              onPressed: () {
                AccountService.find.saveNotFirstLaunch();
                Get.offAllNamed(Routes.main);
              },
            ),
          ),
        )
      ],
    );
  }
}
