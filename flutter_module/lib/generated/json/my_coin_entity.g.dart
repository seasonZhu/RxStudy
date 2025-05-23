import 'package:flutter_module/generated/json/base/json_convert_content.dart';
import 'package:flutter_module/entity/my_coin_entity.dart';

MyCoinEntity $MyCoinEntityFromJson(Map<String, dynamic> json) {
  final MyCoinEntity myCoinEntity = MyCoinEntity();
  final int? coinCount = jsonConvert.convert<int>(json['coinCount']);
  if (coinCount != null) {
    myCoinEntity.coinCount = coinCount;
  }
  final int? level = jsonConvert.convert<int>(json['level']);
  if (level != null) {
    myCoinEntity.level = level;
  }
  final String? nickname = jsonConvert.convert<String>(json['nickname']);
  if (nickname != null) {
    myCoinEntity.nickname = nickname;
  }
  final String? rank = jsonConvert.convert<String>(json['rank']);
  if (rank != null) {
    myCoinEntity.rank = rank;
  }
  final int? userId = jsonConvert.convert<int>(json['userId']);
  if (userId != null) {
    myCoinEntity.userId = userId;
  }
  final String? username = jsonConvert.convert<String>(json['username']);
  if (username != null) {
    myCoinEntity.username = username;
  }
  return myCoinEntity;
}

Map<String, dynamic> $MyCoinEntityToJson(MyCoinEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['coinCount'] = entity.coinCount;
  data['level'] = entity.level;
  data['nickname'] = entity.nickname;
  data['rank'] = entity.rank;
  data['userId'] = entity.userId;
  data['username'] = entity.username;
  return data;
}
