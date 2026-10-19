import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_module/pages/common/empty_view.dart';
import 'package:flutter_module/pages/common/unknown_page.dart';

void main() {
  testWidgets('空数据页面展示提示并响应重试', (tester) async {
    var retries = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: EmptyView(emptyTap: () => retries++)),
    ));

    expect(find.text('暂无数据'), findsOneWidget);
    await tester.tap(find.text('暂无数据'));
    expect(retries, 1);
  });

  testWidgets('未知路由页面正常展示', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: UnknownPage()));
    expect(find.text('未知页面'), findsNWidgets(2));
  });
}
