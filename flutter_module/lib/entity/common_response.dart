import 'package:json_annotation/json_annotation.dart';

part'common_response.g.dart'; // 生成的文件名

@JsonSerializable()
class CommonResponse {
  final String name;
  final int age;
  final bool isStudent;

  CommonResponse({required this.name, required this.age, required this.isStudent});

  factory CommonResponse.fromJson(Map<String, dynamic> json) => _$CommonResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CommonResponseToJson(this);
}