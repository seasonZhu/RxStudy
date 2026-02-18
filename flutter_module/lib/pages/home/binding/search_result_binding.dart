import 'package:flutter_module/base/class_name.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

import 'package:flutter_module/pages/home/controller/search_result_controller.dart';
import 'package:flutter_module/pages/home/repository/search_result_repository.dart';

class SearchResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SearchResultRepository(),
    );
    Get.lazyPut(
      tag: className(SearchResultController),
      () => RefreshController(initialRefresh: true),
    );
    Get.lazyPut<int>(
      tag: className(SearchResultController),
      () => 1,
    );
    Get.lazyPut(
      () => SearchResultController(),
    );
  }
}
