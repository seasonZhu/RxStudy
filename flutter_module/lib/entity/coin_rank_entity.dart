import 'package:flutter_module/generated/json/base/json_field.dart';
import 'package:flutter_module/generated/json/coin_rank_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class CoinRankEntity {
  int? curPage;
  List<CoinRankDatas>? datas;
  int? offset;
  bool? over;
  int? pageCount;
  int? size;
  int? total;

  CoinRankEntity();

  factory CoinRankEntity.fromJson(Map<String, dynamic> json) =>
      $CoinRankEntityFromJson(json);

  Map<String, dynamic> toJson() => $CoinRankEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class CoinRankDatas {
  int? coinCount;
  int? level;
  int? rank;
  int? userId;
  String? username;

  CoinRankDatas();

  factory CoinRankDatas.fromJson(Map<String, dynamic> json) =>
      $CoinRankDatasFromJson(json);

  Map<String, dynamic> toJson() => $CoinRankDatasToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
