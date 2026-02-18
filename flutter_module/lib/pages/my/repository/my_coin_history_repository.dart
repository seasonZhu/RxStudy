import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/entity/base_entity.dart';
import 'package:flutter_module/entity/my_coin_history_entity.dart';
import 'package:flutter_module/entity/page_entity.dart';
import 'package:flutter_module/http_util/request.dart' as http;
import 'package:flutter_module/http_util/api.dart';

class MyCoinHistoryRepository extends IRepository {
  Future<BaseEntity<PageEntity<List<MyCoinHistoryDatas>>>> getCoinRankList(
          int page) =>
      http.Request.get(api: "${Api.getCoinList}${page.toString()}/json");
}
