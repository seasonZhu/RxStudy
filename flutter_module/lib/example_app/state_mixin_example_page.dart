import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_module/pages/home/repository/hot_key_repository.dart';
import 'package:flutter_module/entity/hot_key_entity.dart';

/// 在这里我使用Getx自带的StateMixin在Controller层改变状态,在Page层通过状态改变页面展示

class StateMixinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => StateMixinController(),
    );
  }
}

class StateMixinController extends GetxController
    with StateMixin<List<HotKeyEntity>> {
  late HotKeyRepository request;

  @override
  void onInit() async {
    super.onInit();
    request = HotKeyRepository();
    aRequest();
  }

  Future<void> aRequest({Map<String, dynamic>? parameters}) async {
    /// 这里这个可有可无
    change(null, status: RxStatus.loading());
    final response = await request.getHotKey().catchError((error) {
      change(null, status: RxStatus.error());
      return error;
    });
    final data = response.data ?? [];
    if (response.isSuccess) {
      if (data.isEmpty) {
        change(data, status: RxStatus.empty());
      } else {
        change(data, status: RxStatus.success());
      }
    } else {
      change(data, status: RxStatus.error(response.errorMsg));
    }
  }
}

class StateMixinExamplePage extends GetView<StateMixinController> {
  const StateMixinExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("StateMixin例子"),
      ),
      child: Center(
        child: controller.obx(
          (list) => Wrap(
            children: (list ?? []).map(
              (model) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          const WidgetStatePropertyAll(Colors.blue),
                      foregroundColor:
                          const WidgetStatePropertyAll(Colors.white),
                      overlayColor: const WidgetStatePropertyAll(Colors.blue),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: Text(model.name.toString()),
                    onPressed: () {},
                  ),
                );
              },
            ).toList(),
          ),
          onLoading: const CupertinoActivityIndicator(),
          onEmpty: const Text('No data found'),
          onError: (error) => Text(error.toString()),
        ),
      ),
    );
  }
}

/*
/// 一般情况做动画需要这样
class _MyState extends State<MynPage> with TickerProviderStateMixin {
 */

class MyAnimationPresenter extends GetxController
    with GetSingleTickerProviderStateMixin {
  final int durationInMs;
  late AnimationController animCtrl;

  MyAnimationPresenter({required this.durationInMs}) {
    animCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationInMs),
    );
  }
}

class SomeRepository extends GetxService {}

class CounterController extends GetxController with StateMixin<int> {
  void increment() {
    // 更新状态值并设置为成功状态
    change((state ?? 0) + 1, status: RxStatus.success());
  }

  void reset() {
    // 重置状态值并设置为空状态
    change(0, status: RxStatus.empty());
  }

  void simulateError() {
    // 模拟错误状态
    change(state, status: RxStatus.error("An error occurred"));
  }
}

class CounterPage extends StatelessWidget {
  final CounterController controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("StateMixin Example")),
      body: controller.obx(
        (state) => Center(
          child: Text("Count: $state", style: TextStyle(fontSize: 24)),
        ),
        onLoading: Center(child: CircularProgressIndicator()),
        onError: (error) => Center(child: Text("Error: $error")),
        onEmpty: Center(child: Text("No data available")),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: controller.increment,
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: controller.reset,
            child: Icon(Icons.refresh),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: controller.simulateError,
            child: Icon(Icons.error),
          ),
        ],
      ),
    );
  }
}
