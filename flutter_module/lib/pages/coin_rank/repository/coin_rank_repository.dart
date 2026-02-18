import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/entity/base_entity.dart';
import 'package:flutter_module/entity/coin_rank_entity.dart';
import 'package:flutter_module/entity/page_entity.dart';
import 'package:flutter_module/http_util/request.dart' as http;
import 'package:flutter_module/http_util/api.dart';

class CoinRankRepository extends IRepository {
  Future<BaseEntity<PageEntity<List<CoinRankDatas>>>> getCoinRankList(
          int page) =>
      http.Request.get(api: "${Api.getRankingList}${page.toString()}/json");
}
