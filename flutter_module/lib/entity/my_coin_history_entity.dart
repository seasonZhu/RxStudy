import 'package:flutter_module/generated/json/base/json_field.dart';
import 'package:flutter_module/generated/json/my_coin_history_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class MyCoinHistoryEntity {
  int? curPage;
  List<MyCoinHistoryDatas>? datas;
  int? offset;
  bool? over;
  int? pageCount;
  int? size;
  int? total;

  MyCoinHistoryEntity();

  factory MyCoinHistoryEntity.fromJson(Map<String, dynamic> json) =>
      $MyCoinHistoryEntityFromJson(json);

  Map<String, dynamic> toJson() => $MyCoinHistoryEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class MyCoinHistoryDatas {
  int? coinCount;
  int? date;
  String? desc;
  int? id;
  String? reason;
  int? type;
  int? userId;
  String? userName;

  MyCoinHistoryDatas();

  factory MyCoinHistoryDatas.fromJson(Map<String, dynamic> json) =>
      $MyCoinHistoryDatasFromJson(json);

  Map<String, dynamic> toJson() => $MyCoinHistoryDatasToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
