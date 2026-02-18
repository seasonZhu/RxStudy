import 'package:flutter_module/generated/json/base/json_convert_content.dart';
import 'package:flutter_module/entity/my_coin_history_entity.dart';

MyCoinHistoryEntity $MyCoinHistoryEntityFromJson(Map<String, dynamic> json) {
  final MyCoinHistoryEntity myCoinHistoryEntity = MyCoinHistoryEntity();
  final int? curPage = jsonConvert.convert<int>(json['curPage']);
  if (curPage != null) {
    myCoinHistoryEntity.curPage = curPage;
  }
  final List<MyCoinHistoryDatas>? datas =
      jsonConvert.convertListNotNull<MyCoinHistoryDatas>(json['datas']);
  if (datas != null) {
    myCoinHistoryEntity.datas = datas;
  }
  final int? offset = jsonConvert.convert<int>(json['offset']);
  if (offset != null) {
    myCoinHistoryEntity.offset = offset;
  }
  final bool? over = jsonConvert.convert<bool>(json['over']);
  if (over != null) {
    myCoinHistoryEntity.over = over;
  }
  final int? pageCount = jsonConvert.convert<int>(json['pageCount']);
  if (pageCount != null) {
    myCoinHistoryEntity.pageCount = pageCount;
  }
  final int? size = jsonConvert.convert<int>(json['size']);
  if (size != null) {
    myCoinHistoryEntity.size = size;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    myCoinHistoryEntity.total = total;
  }
  return myCoinHistoryEntity;
}

Map<String, dynamic> $MyCoinHistoryEntityToJson(MyCoinHistoryEntity entity) {
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

MyCoinHistoryDatas $MyCoinHistoryDatasFromJson(Map<String, dynamic> json) {
  final MyCoinHistoryDatas myCoinHistoryDatas = MyCoinHistoryDatas();
  final int? coinCount = jsonConvert.convert<int>(json['coinCount']);
  if (coinCount != null) {
    myCoinHistoryDatas.coinCount = coinCount;
  }
  final int? date = jsonConvert.convert<int>(json['date']);
  if (date != null) {
    myCoinHistoryDatas.date = date;
  }
  final String? desc = jsonConvert.convert<String>(json['desc']);
  if (desc != null) {
    myCoinHistoryDatas.desc = desc;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    myCoinHistoryDatas.id = id;
  }
  final String? reason = jsonConvert.convert<String>(json['reason']);
  if (reason != null) {
    myCoinHistoryDatas.reason = reason;
  }
  final int? type = jsonConvert.convert<int>(json['type']);
  if (type != null) {
    myCoinHistoryDatas.type = type;
  }
  final int? userId = jsonConvert.convert<int>(json['userId']);
  if (userId != null) {
    myCoinHistoryDatas.userId = userId;
  }
  final String? userName = jsonConvert.convert<String>(json['userName']);
  if (userName != null) {
    myCoinHistoryDatas.userName = userName;
  }
  return myCoinHistoryDatas;
}

Map<String, dynamic> $MyCoinHistoryDatasToJson(MyCoinHistoryDatas entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['coinCount'] = entity.coinCount;
  data['date'] = entity.date;
  data['desc'] = entity.desc;
  data['id'] = entity.id;
  data['reason'] = entity.reason;
  data['type'] = entity.type;
  data['userId'] = entity.userId;
  data['userName'] = entity.userName;
  return data;
}
