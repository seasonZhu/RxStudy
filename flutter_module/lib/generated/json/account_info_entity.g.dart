import 'package:flutter_module/generated/json/base/json_convert_content.dart';
import 'package:flutter_module/entity/account_info_entity.dart';

AccountInfoEntity $AccountInfoEntityFromJson(Map<String, dynamic> json) {
  final AccountInfoEntity accountInfoEntity = AccountInfoEntity();
  final bool? admin = jsonConvert.convert<bool>(json['admin']);
  if (admin != null) {
    accountInfoEntity.admin = admin;
  }
  final List<int>? chapterTops =
      jsonConvert.convertListNotNull<int>(json['chapterTops']);
  if (chapterTops != null) {
    accountInfoEntity.chapterTops = chapterTops;
  }
  final List<int>? collectIds =
      jsonConvert.convertListNotNull<int>(json['collectIds']);
  if (collectIds != null) {
    accountInfoEntity.collectIds = collectIds;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    accountInfoEntity.email = email;
  }
  final String? icon = jsonConvert.convert<String>(json['icon']);
  if (icon != null) {
    accountInfoEntity.icon = icon;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    accountInfoEntity.id = id;
  }
  final String? nickname = jsonConvert.convert<String>(json['nickname']);
  if (nickname != null) {
    accountInfoEntity.nickname = nickname;
  }
  final String? password = jsonConvert.convert<String>(json['password']);
  if (password != null) {
    accountInfoEntity.password = password;
  }
  final String? publicName = jsonConvert.convert<String>(json['publicName']);
  if (publicName != null) {
    accountInfoEntity.publicName = publicName;
  }
  final String? token = jsonConvert.convert<String>(json['token']);
  if (token != null) {
    accountInfoEntity.token = token;
  }
  final int? type = jsonConvert.convert<int>(json['type']);
  if (type != null) {
    accountInfoEntity.type = type;
  }
  final String? username = jsonConvert.convert<String>(json['username']);
  if (username != null) {
    accountInfoEntity.username = username;
  }
  return accountInfoEntity;
}

Map<String, dynamic> $AccountInfoEntityToJson(AccountInfoEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['admin'] = entity.admin;
  data['chapterTops'] = entity.chapterTops;
  data['collectIds'] = entity.collectIds;
  data['email'] = entity.email;
  data['icon'] = entity.icon;
  data['id'] = entity.id;
  data['nickname'] = entity.nickname;
  data['password'] = entity.password;
  data['publicName'] = entity.publicName;
  data['token'] = entity.token;
  data['type'] = entity.type;
  data['username'] = entity.username;
  return data;
}
