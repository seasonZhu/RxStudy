import 'package:flutter_module/generated/json/base/json_field.dart';
import 'package:flutter_module/generated/json/my_coin_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class MyCoinEntity {
  int? coinCount;
  int? level;
  String? nickname;
  String? rank;
  int? userId;
  String? username;

  MyCoinEntity();

  factory MyCoinEntity.fromJson(Map<String, dynamic> json) =>
      $MyCoinEntityFromJson(json);

  Map<String, dynamic> toJson() => $MyCoinEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  /// Dart的可选类型没有解包运算符https://cloud.tencent.com/developer/ask/sof/1357979/answer/1869854
  String get userInfo {
    if (rank != null && level != null && coinCount != null) {
      return "排名: $rank! 等级: $level 积分: $coinCount";
    } else {
      return "排名: -- 等级: -- 积分: --";
    }
  }
}
