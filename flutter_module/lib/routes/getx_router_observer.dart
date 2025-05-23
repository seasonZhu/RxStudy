import 'package:flutter/material.dart';

import 'package:get/get_navigation/src/router_report.dart';

GetXRouterObserver getXRouterObserver = GetXRouterObserver();

class GetXRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    RouterReportManager.reportCurrentRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    RouterReportManager.reportRouteDispose(route);
  }
}
