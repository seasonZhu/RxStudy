import 'package:flutter_module/generated/json/base/json_convert_content.dart';
import 'package:flutter_module/entity/tab_entity.dart';

TabEntity $TabEntityFromJson(Map<String, dynamic> json) {
  final TabEntity tabEntity = TabEntity();
  final List<TabEntity>? children =
      jsonConvert.convertListNotNull<TabEntity>(json['children']);
  if (children != null) {
    tabEntity.children = children;
  }
  final int? courseId = jsonConvert.convert<int>(json['courseId']);
  if (courseId != null) {
    tabEntity.courseId = courseId;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    tabEntity.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    tabEntity.name = name;
  }
  final int? order = jsonConvert.convert<int>(json['order']);
  if (order != null) {
    tabEntity.order = order;
  }
  final int? parentChapterId =
      jsonConvert.convert<int>(json['parentChapterId']);
  if (parentChapterId != null) {
    tabEntity.parentChapterId = parentChapterId;
  }
  final bool? userControlSetTop =
      jsonConvert.convert<bool>(json['userControlSetTop']);
  if (userControlSetTop != null) {
    tabEntity.userControlSetTop = userControlSetTop;
  }
  final int? visible = jsonConvert.convert<int>(json['visible']);
  if (visible != null) {
    tabEntity.visible = visible;
  }
  return tabEntity;
}

Map<String, dynamic> $TabEntityToJson(TabEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['children'] = entity.children?.map((v) => v.toJson()).toList();
  data['courseId'] = entity.courseId;
  data['id'] = entity.id;
  data['name'] = entity.name;
  data['order'] = entity.order;
  data['parentChapterId'] = entity.parentChapterId;
  data['userControlSetTop'] = entity.userControlSetTop;
  data['visible'] = entity.visible;
  return data;
}
