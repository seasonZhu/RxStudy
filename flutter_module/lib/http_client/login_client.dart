import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:flutter_module/entity/base_entity.dart';
import 'package:flutter_module/entity/banner_entity.dart';

part 'login_client.g.dart';

const timeout = Duration(seconds: 60);

final _dio = Dio(
  BaseOptions(
    baseUrl: "https://www.wanandroid.com/",
    connectTimeout: timeout,
    receiveTimeout: timeout,
    headers: {"name": "season"},
  ),
);

/// 通过不同的client来区分不同的业务,一般情况下对于非登录和登录,使用不同的client来进行网络请求,
/// 另外,只有创建这个文件,然后把`part 'login_client.g.dart';`标注好,硬着头皮跑脚本就完事了
/// 回想一下,其实只需要细分不同_dio,就可以差异化不同的业务以及登录与非登录状态
final loginClient = LoginClient(_dio);

@RestApi(
  // 请求域名
  baseUrl: 'https://www.wanandroid.com/',
  // 数据解析方式，默认为json
  parser: Parser.JsonSerializable,
)
abstract class LoginClient {
  // 标准的构建方式
  // dio: 传入发起网络请求的对象
  // baseUrl: 请求域名，优先级高于注解
  factory LoginClient(Dio dio, {String baseUrl}) = _LoginClient;

  @GET("banner/json")
  Future<BaseEntity<List<BannerEntity>>> getBanner();
}
