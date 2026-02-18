import 'package:flutter_module/generated/json/base/json_field.dart';
import 'package:flutter_module/generated/json/account_info_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class AccountInfoEntity {
  bool? admin;
  List<int>? chapterTops;
  List<int>? collectIds;
  String? email;
  String? icon;
  int? id;
  String? nickname;
  String? password;
  String? publicName;
  String? token;
  int? type;
  String? username;

  AccountInfoEntity();

  factory AccountInfoEntity.fromJson(Map<String, dynamic> json) =>
      $AccountInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $AccountInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
