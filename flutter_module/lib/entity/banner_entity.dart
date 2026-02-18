import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/generated/json/base/json_field.dart';
import 'package:flutter_module/generated/json/banner_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class BannerEntity implements IWebLoadInfo {
  String? desc;
  @override
  int? id;
  String? imagePath;
  double? isVisible;
  double? order;
  @override
  String? title;
  double? type;
  String? url;
  @override
  String? link;
  @override
  int? originId;

  BannerEntity();

  factory BannerEntity.fromJson(Map<String, dynamic> json) =>
      $BannerEntityFromJson(json);

  Map<String, dynamic> toJson() => $BannerEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
