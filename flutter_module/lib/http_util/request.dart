import 'dart:async';

import 'http_util.dart';

import 'package:flutter_module/entity/base_entity.dart';

extension Request on HttpUtils {
  /// Get请求直接转模型
  static Future<BaseEntity<T>> get<T>(
      {required String api, Map<String, dynamic> params = const {}}) async {
    final data = await HttpUtils.get(api: api, params: params);
    final model = BaseEntity<T>.fromJson(data);
    return model;
  }

  /// Post请求
  static Future<BaseEntity<T>> post<T>(
      {required String api, Map<String, dynamic> params = const {}}) async {
    final data = await HttpUtils.post(api: api, params: params);
    final model = BaseEntity<T>.fromJson(data);
    return model;
  }
}
