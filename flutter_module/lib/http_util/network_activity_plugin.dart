import 'package:dio/dio.dart';

/// 如果想要监听请求过程,用Dio自带的InterceptorsWrapper就可以了

enum NetworkActivityChangeType {
  began,
  ended;
}

typedef NetworkActivityCallback = void Function(
    NetworkActivityChangeType change, RequestOptions options);

class NetworkActivityPlugin extends Interceptor {
  late NetworkActivityCallback networkActivityCallback;

  NetworkActivityPlugin({
    required this.networkActivityCallback,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    networkActivityCallback(NetworkActivityChangeType.began, options);
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    networkActivityCallback(
        NetworkActivityChangeType.ended, err.requestOptions);
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    networkActivityCallback(
        NetworkActivityChangeType.ended, response.requestOptions);
    super.onResponse(response, handler);
  }
}
