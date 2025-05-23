import 'package:flutter_module/channel/channel.dart';
import 'package:get/get.dart';
import 'package:flutter_module/logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  var selectedIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _listenMethodChannel();
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    update();

    //getFindTest();
  }

  void getFindTest() {
    /// Get.putAsyn使用的时候要稍微注意,避免先find后put
    final prefs = Get.find<SharedPreferences>();
    int? count = prefs.getInt('counter');
    logger.d(count);
  }

  void _listenMethodChannel() {
    methodChannel.setMethodCallHandler((call) {
      final method = call.method;
      final jsonString = call.arguments;
      logger.d("从Native侧传递过来的方法: $method");
      logger.d("从Native侧传递过来的参数: $jsonString");

      return Future.value("收到从Native传来的位置信息,这里是Flutter的返回的信息");
    });
  }
}
