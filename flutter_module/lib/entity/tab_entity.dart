import 'package:flutter_module/generated/json/base/json_field.dart';
import 'package:flutter_module/generated/json/tab_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class TabEntity {
  List<TabEntity>? children;
  int? courseId;
  int? id;
  String? name;
  int? order;
  int? parentChapterId;
  bool? userControlSetTop;
  int? visible;

  TabEntity();

  factory TabEntity.fromJson(Map<String, dynamic> json) =>
      $TabEntityFromJson(json);

  Map<String, dynamic> toJson() => $TabEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
