import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

import 'api.dart';
import 'http_status.dart' as season;
import 'plugins.dart';
import 'package:flutter_module/app_service/account_service.dart';

/// 这个是用来判断是否是生产环境
const bool inProduction = bool.fromEnvironment("dart.vm.product");

abstract class HttpUtils {
  // 超时时间 1min dio中是以毫秒计算的
  static const timeout = Duration(seconds: 60);

  HttpUtils._();

  static final _dio = Dio(
    BaseOptions(
      baseUrl: Api.baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      headers: {},
    ),
  ).addPlugins;

  // Get请求
  static Future<Map<String, dynamic>> get(
      {required String api,
      Map<String, dynamic> params = const {},
      Map<String, dynamic> headers = const {}}) async {
    getCookieHeaderOptions().headers?.addAll(headers);
    Response response = await _dio.get(api,
        queryParameters: params, options: getCookieHeaderOptions());
    Map<String, dynamic> json = response.data;
    return json;
  }

  // Post请求
  static Future<Map<String, dynamic>> post(
      {required String api,
      Map<String, dynamic> params = const {},
      Map<String, dynamic> headers = const {}}) async {
    getCookieHeaderOptions().headers?.addAll(headers);

    /// 这个地方必须用queryParameters,用data传入就报错了
    /// 这个地方其实是玩安卓的API比较奇葩,一般post请求,参数都是放到request的body中,而它的还是拼接到网址后面
    Response response = await _dio.post(api,
        queryParameters: params, options: getCookieHeaderOptions());
    Map<String, dynamic> json = response.data;
    return json;
  }

  static Options getCookieHeaderOptions() {
    final value = AccountService.find.cookieHeaderValue;
    Options options = Options(headers: {HttpHeaders.cookieHeader: value});
    return options;
  }

  Future<Response<T>> request<T>(String api,
      {required HTTPMethod method,
      dynamic data,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic> headers = const {}}) async {
    Response response = await _dio.request(
      api,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers, method: method.string),
    );
    return response.data;
  }
}

extension Plugins on Dio {
  Dio get addPlugins {
    interceptors.addAll([
      loggerPlugin,
      networkActivityPlugin,
      responseInterceptorPlugin,
    ]);
    return this;
  }

  Dio get addNativeAdapter {
    if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
      httpClientAdapter = NativeAdapter();
    }
    return this;
  }
}

enum HTTPMethod {
  get("GET"),
  post("POST"),
  delete("DELETE"),
  put("PUT"),
  patch("PATCH"),
  head("HEAD");

  final String string;

  const HTTPMethod(this.string);
}

extension EnumStatus on Response {
  season.HttpStatus get status =>
      season.HttpStatus.mappingTable[statusCode] ??
      season.HttpStatus.connectionError;
}
