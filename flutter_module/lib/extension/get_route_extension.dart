import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:flutter_module/routes/history_router_observer.dart';

/// https://juejin.cn/post/7283315133140107304
extension GetRouteExtension on GetInterface {
  ///路由历史
  List<Route<dynamic>> get history => historyRouterObserver.history;

  ///是否已打开该页面
  bool containName(String name) {
    return getRouteByName(name) != null;
  }

  ///通过name获取route，从栈顶开始查找
  Route? getRouteByName(String name) {
    var index =
        history.lastIndexWhere((element) => element.settings.name == name);
    if (index != -1) {
      return history[index];
    }
    return null;
  }

  ///通过name获取route
  List<Route> getRoutesByName(String name) {
    return history.where((element) => element.settings.name == name).toList();
  }

  ///移除指定的页面,一次
  void removeName(String name) {
    var route = getRouteByName(name);
    if (route != null) {
      if (history.last == route) {
        //移除当前页面，直接返回
        Get.back();
      } else {
        Get.removeRoute(route);
      }
    }
  }

  ///移除所有指定的页面
  void removeAllName(String name) {
    var routes = getRoutesByName(name);
    for (var route in routes) {
      Get.removeRoute(route);
    }
  }
}
