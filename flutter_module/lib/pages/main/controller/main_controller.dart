import 'package:get/get.dart';
import 'package:flutter_module/logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  var selectedIndex = 0;

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
}
