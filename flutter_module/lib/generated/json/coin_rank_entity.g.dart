import 'package:flutter_module/generated/json/base/json_convert_content.dart';
import 'package:flutter_module/entity/coin_rank_entity.dart';

CoinRankEntity $CoinRankEntityFromJson(Map<String, dynamic> json) {
  final CoinRankEntity coinRankEntity = CoinRankEntity();
  final int? curPage = jsonConvert.convert<int>(json['curPage']);
  if (curPage != null) {
    coinRankEntity.curPage = curPage;
  }
  final List<CoinRankDatas>? datas =
      jsonConvert.convertListNotNull<CoinRankDatas>(json['datas']);
  if (datas != null) {
    coinRankEntity.datas = datas;
  }
  final int? offset = jsonConvert.convert<int>(json['offset']);
  if (offset != null) {
    coinRankEntity.offset = offset;
  }
  final bool? over = jsonConvert.convert<bool>(json['over']);
  if (over != null) {
    coinRankEntity.over = over;
  }
  final int? pageCount = jsonConvert.convert<int>(json['pageCount']);
  if (pageCount != null) {
    coinRankEntity.pageCount = pageCount;
  }
  final int? size = jsonConvert.convert<int>(json['size']);
  if (size != null) {
    coinRankEntity.size = size;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    coinRankEntity.total = total;
  }
  return coinRankEntity;
}

Map<String, dynamic> $CoinRankEntityToJson(CoinRankEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['curPage'] = entity.curPage;
  data['datas'] = entity.datas?.map((v) => v.toJson()).toList();
  data['offset'] = entity.offset;
  data['over'] = entity.over;
  data['pageCount'] = entity.pageCount;
  data['size'] = entity.size;
  data['total'] = entity.total;
  return data;
}

CoinRankDatas $CoinRankDatasFromJson(Map<String, dynamic> json) {
  final CoinRankDatas coinRankDatas = CoinRankDatas();
  final int? coinCount = jsonConvert.convert<int>(json['coinCount']);
  if (coinCount != null) {
    coinRankDatas.coinCount = coinCount;
  }
  final int? level = jsonConvert.convert<int>(json['level']);
  if (level != null) {
    coinRankDatas.level = level;
  }
  final int? rank = jsonConvert.convert<int>(json['rank']);
  if (rank != null) {
    coinRankDatas.rank = rank;
  }
  final int? userId = jsonConvert.convert<int>(json['userId']);
  if (userId != null) {
    coinRankDatas.userId = userId;
  }
  final String? username = jsonConvert.convert<String>(json['username']);
  if (username != null) {
    coinRankDatas.username = username;
  }
  return coinRankDatas;
}

Map<String, dynamic> $CoinRankDatasToJson(CoinRankDatas entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['coinCount'] = entity.coinCount;
  data['level'] = entity.level;
  data['rank'] = entity.rank;
  data['userId'] = entity.userId;
  data['username'] = entity.username;
  return data;
}
