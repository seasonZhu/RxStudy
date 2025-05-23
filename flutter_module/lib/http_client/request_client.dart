import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_module/app_service/account_service.dart';
import 'package:flutter_module/entity/common_response.dart';
import 'package:flutter_module/http_util/http_util.dart';

import 'package:flutter_module/http_util/api.dart';
import 'package:flutter_module/entity/base_entity.dart';
import 'package:flutter_module/entity/banner_entity.dart';
import 'package:flutter_module/entity/article_info_entity.dart';
import 'package:flutter_module/entity/page_entity.dart';
import 'package:flutter_module/entity/hot_key_entity.dart';
import 'package:flutter_module/entity/tab_entity.dart';
import 'package:flutter_module/entity/account_info_entity.dart';
import 'package:flutter_module/entity/coin_rank_entity.dart';
import 'package:flutter_module/entity/my_coin_history_entity.dart';
import 'package:retrofit/retrofit.dart';

part 'request_client.g.dart';

/// 参看 说明.md中的执行脚本
/*
dart pub run build_runner build

flutter pub run build_runner build

个人更建议使用 watch 命令
该命令监听输入，可以实时编译最新的代码，不用每次修改之后重复使用 build 了
flutter pub run build_runner watch
*/

const timeout = Duration(seconds: 60);

final _dio = Dio(
  BaseOptions(
    baseUrl: Api.baseUrl,
    connectTimeout: timeout,
    receiveTimeout: timeout,
    headers: {HttpHeaders.cookieHeader: AccountService.find.cookieHeaderValue},
  ),
).addPlugins;

final requestClient = RequestClient(_dio);

@RestApi(
  // 请求域名
  baseUrl: Api.baseUrl,
  // 数据解析方式，默认为json
  parser: Parser.JsonSerializable,
)
abstract class RequestClient {
  // 标准的构建方式
  // dio: 传入发起网络请求的对象
  // baseUrl: 请求域名，优先级高于注解
  factory RequestClient(Dio dio, {String baseUrl}) = _RequestClient;

  @GET("banner/json")
  Future<BaseEntity<List<BannerEntity>>> getBanner();

  @GET("article/list/{page}/json")
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getArticleList(
      @Path() int page);

  @GET("article/top/json")
  Future<BaseEntity<List<ArticleInfoDatas>>> getTopArticleList();

  @GET("getSearchHotKey")
  Future<BaseEntity<List<HotKeyEntity>>> getSearchHotKey();

  @POST("article/query/{page}/json")
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> searchKeyword(
      @Path() int page, @Query("k") String keyword);

  @GET("project/tree/json")
  Future<BaseEntity<List<TabEntity>>> getProjectTab();

  @GET("project/list/{page}/json")
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>>
      getCurrentProjectTabList(@Path() int page, @Query("cid") String id);

  @GET("wxarticle/chapters/json")
  Future<BaseEntity<List<TabEntity>>> getWXArticleTab();

  @GET("wxarticle/list/{id}/{page}/json")
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>>
      getCurrentWXArticleTabList(@Path() String id, @Path() int page);

  @POST("user/login")
  Future<BaseEntity<AccountInfoEntity>> login(
      @Query("username") String username, @Query("password") String password);

  @POST("user/register")
  Future<BaseEntity<AccountInfoEntity>> register(
      @Query("username") String username,
      @Query("password") String password,
      @Query("repassword") String repassword);

  @GET("user/logout/json")
  Future<BaseEntity<Object?>> logout();

  @POST("lg/collect/{id}/json")
  Future<BaseEntity<Object?>> collectAction(@Path() int originId);

  @POST("lg/uncollect_originId/{id}/json")
  Future<BaseEntity<Object?>> unCollectAction(@Path() int originId);

  @GET("lg/collect/list/{page}/json")
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getCollectArticleList(
      @Path() int page);

  @GET("coin/rank/{page}/json")
  Future<BaseEntity<PageEntity<List<CoinRankDatas>>>> getCoinRankList(
      @Path() int page);

  @GET("lg/coin/list/{page}/json")
  Future<BaseEntity<PageEntity<List<MyCoinHistoryDatas>>>> getMyCoinList(
      @Path() int page);

  @GET("lg/coin/userinfo/json")
  Future<BaseEntity<CoinRankDatas>> getUserCoinInfo();

  @GET("tree/json")
  Future<BaseEntity<List<TabEntity>>> getTreeTab();

  @GET("article/list/{id}/{page}/json")
  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getCurrentTreeTabList(
      @Path() String id, @Path() int page);

  @GET("tree/json")
  Future<BaseEntity<CommonResponse>> getExample();
}
