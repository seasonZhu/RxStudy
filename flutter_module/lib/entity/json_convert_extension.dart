import 'package:flutter_module/generated/json/base/json_convert_content.dart';

import 'package:flutter_module/entity/article_info_entity.dart';
import 'package:flutter_module/entity/coin_rank_entity.dart';
import 'package:flutter_module/entity/my_coin_history_entity.dart';
import 'package:flutter_module/entity/page_entity.dart';

extension MoreGenerics on JsonConvert {
  /// 解决泛型里面包含泛型的转换问题
  static final Map<String, JsonConvertFunction> genericsFuncMap = {
    "PageEntity<List<CoinRankDatas>>": PageEntity<List<CoinRankDatas>>.fromJson,
    "PageEntity<List<ArticleInfoDatas>>":
        PageEntity<List<ArticleInfoDatas>>.fromJson,
    "PageEntity<List<MyCoinHistoryDatas>>":
        PageEntity<List<MyCoinHistoryDatas>>.fromJson,
  };
}
