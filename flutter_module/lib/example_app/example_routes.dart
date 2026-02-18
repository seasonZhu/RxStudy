import 'package:get/get.dart';
import 'package:flutter_module/example_app/get_x_app.dart';

abstract class Routes {
  Routes._();

  static const getXExamplePage = "/getXExamplePage";

  static const getxRxExamplePage = "/getxRxExamplePage";

  ///页面合集
  static final routePage = [
    GetPage(
      name: getXExamplePage,
      page: () => const GetXExamplePage(),
      binding: GetXExampleBindings(),
    ),
    GetPage(
      name: getxRxExamplePage,
      page: () => GetxRxExamplePage(),
      binding: GetxRxExampleBindings(),
    ),
  ];
}
