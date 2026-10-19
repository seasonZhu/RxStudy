import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/channel/channel.dart';
import 'package:flutter_module/channel/native_channel_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const codec = StandardMethodCodec();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Future<dynamic> receive(String method, [dynamic arguments]) {
    final result = Completer<dynamic>();
    messenger.handlePlatformMessage(
      methodChannel.name,
      codec.encodeMethodCall(MethodCall(method, arguments)),
      (ByteData? data) {
        try {
          if (data == null) throw MissingPluginException();
          result.complete(codec.decodeEnvelope(data));
        } catch (error, stack) {
          result.completeError(error, stack);
        }
      },
    );
    return result.future;
  }

  test('欢迎页创建前完成握手，未创建我的页面也能同步账号', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    final account = Get.put(AccountService());
    final bridge = NativeChannelBridge();
    var handshakes = 0;
    var eventListens = 0;
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      expect(call.method, 'ready');
      handshakes++;
      // ready 发出时，原生已经可以回调 Dart；无需等待任何页面控制器。
      await receive('nativeLogin', '{"username":"测试用户","password":"测试密码"}');
      return null;
    });
    messenger.setMockMethodCallHandler(const MethodChannel('nativeEvent'),
        (call) async {
      if (call.method == 'listen') eventListens++;
      return null;
    });
    try {
      await bridge.start();
      await bridge.start();
      expect(handshakes, 1);
      expect(eventListens, 1);
      expect(account.isLogin, isTrue);
      expect(await account.getLastLoginUserName(), '测试用户');
      await expectLater(
          receive('nativeLogin', '非法 JSON'), throwsA(isA<PlatformException>()));
      expect(account.isLogin, isTrue);
      await receive('nativeLogout');
      expect(account.isLogin, isFalse);
      expect(await account.getLastLoginPassword(), isEmpty);
      expect(handshakes, 1, reason: '原生状态同步不应回传登录或退出消息');
      await expectLater(
          receive('unknown'), throwsA(isA<MissingPluginException>()));
    } finally {
      await bridge.dispose();
      messenger.setMockMethodCallHandler(methodChannel, null);
      messenger.setMockMethodCallHandler(
          const MethodChannel('nativeEvent'), null);
      debugDefaultTargetPlatformOverride = null;
      Get.reset();
    }
  });
}
