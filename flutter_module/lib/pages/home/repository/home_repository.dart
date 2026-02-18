import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/entity/article_info_entity.dart';
import 'package:flutter_module/entity/base_entity.dart';
import 'package:flutter_module/entity/banner_entity.dart';
import 'package:flutter_module/entity/page_entity.dart';
import 'package:flutter_module/http_util/request.dart' as http;
import 'package:flutter_module/http_util/api.dart';
import 'package:flutter_module/http_client/request_client.dart';

class HomeRepository extends IRepository {
  Future<BaseEntity<List<BannerEntity>>> getBanner() =>
      http.Request.get(api: Api.getBanner);

  Future<BaseEntity<List<ArticleInfoDatas>>> getTopArticleList() =>
      http.Request.get(api: Api.getTopArticleList);

  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getArticleList(
          {required int page}) =>
      http.Request.get(api: "${Api.getArticleList}${page.toString()}/json");
}

/* 瞬间觉得自己写的HomeRepository不香了
class HomeRepository extends IRepository {
  Future<BaseEntity<List<BannerEntity>>> getBanner() =>
      requestClient.getBanner();

  Future<BaseEntity<List<ArticleInfoDatas>>> getTopArticleList() =>
      requestClient.getTopArticleList();

  Future<BaseEntity<PageEntity<List<ArticleInfoDatas>>>> getArticleList(
          {required int page}) =>
      requestClient.getArticleList(page);
}
 */
