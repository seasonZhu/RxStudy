import 'package:flutter_module/generated/json/base/json_convert_content.dart';
import 'package:flutter_module/entity/banner_entity.dart';

BannerEntity $BannerEntityFromJson(Map<String, dynamic> json) {
  final BannerEntity bannerEntity = BannerEntity();
  final String? desc = jsonConvert.convert<String>(json['desc']);
  if (desc != null) {
    bannerEntity.desc = desc;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    bannerEntity.id = id;
  }
  final String? imagePath = jsonConvert.convert<String>(json['imagePath']);
  if (imagePath != null) {
    bannerEntity.imagePath = imagePath;
  }
  final double? isVisible = jsonConvert.convert<double>(json['isVisible']);
  if (isVisible != null) {
    bannerEntity.isVisible = isVisible;
  }
  final double? order = jsonConvert.convert<double>(json['order']);
  if (order != null) {
    bannerEntity.order = order;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    bannerEntity.title = title;
  }
  final double? type = jsonConvert.convert<double>(json['type']);
  if (type != null) {
    bannerEntity.type = type;
  }
  final String? url = jsonConvert.convert<String>(json['url']);
  if (url != null) {
    bannerEntity.url = url;
    bannerEntity.link = url;
  }
  return bannerEntity;
}

Map<String, dynamic> $BannerEntityToJson(BannerEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['desc'] = entity.desc;
  data['id'] = entity.id;
  data['imagePath'] = entity.imagePath;
  data['isVisible'] = entity.isVisible;
  data['order'] = entity.order;
  data['title'] = entity.title;
  data['type'] = entity.type;
  data['url'] = entity.url;
  data['link'] = entity.url;
  return data;
}
