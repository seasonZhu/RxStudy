import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'example_routes.dart';
import 'package:flutter_module/extension/theme_data_extension.dart';

class GetXApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: Routes.routePage,
      initialBinding: GetXExampleBindings(),
      home: const GetXExamplePage(),
    );
  }
}

class GetXExamplePage extends GetView<GetXExampleController> {
  const GetXExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GetX编写计数器"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            GetBuilder<GetXExampleController>(
              builder: ((controller) {
                return Text(
                  controller.count.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              }),
            ),
            ElevatedButton(
              onPressed: controller.pushToNextPage,
              child: const Text("下一页"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GetXExampleController extends GetxController {
  var count = 0;

  void increment() {
    ++count;
    update();
  }

  void pushToNextPage() {
    Get.toNamed(Routes.getxRxExamplePage,
        arguments: {"message": "我是GetXExamplePage传来的数据"});
  }
}

class GetXExampleBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetXExampleController());
  }
}

class GetxRxExamplePage extends GetView<GetxRxExampleController> {
  GetxRxExamplePage({Key? key}) : super(key: key);

  final _easyController = Get.find<GetXExampleController>();

  @override
  Widget build(BuildContext context) {
    final map = Get.arguments;
    final message = map["message"];
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: const Text("GetX响应式编写计数器"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Obx(() {
              return Text(
                controller.count.value.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              );
            }),

            /// 使用GetX<T>时,GetxRxExampleController必须继承GetxController
            // GetX<GetxRxExampleController>(
            //   builder: (s) {
            //     return Text(
            //       s.count.value.toString(),
            //       style: Theme.of(context).textTheme.headlineMedium,
            //     );
            //   },
            // ),
            Text(message),
            ElevatedButton(
              onPressed: controller.pushToCoinRankPage,
              child: const Text("下一页"),
            ),
            Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 12),
                      Text("Share")
                    ])).addNeumorphism(
              bottomShadowColor: const Color(0xFFA3B1C6),
              topShadowColor: Colors.white,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          controller.increment();

          /// 上一个页面的值也在进行添加
          _easyController.increment();
        }),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GetxRxExampleBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetxRxExampleController());
  }
}

/// 响应式不用继承GetxController: https://juejin.cn/post/7204854015463997496
class GetxRxExampleController {
  var count = 0.obs;

  void increment() {
    ++count;
  }

  void pushToCoinRankPage() {
    Get.toNamed(Routes.getXExamplePage);
  }
}
