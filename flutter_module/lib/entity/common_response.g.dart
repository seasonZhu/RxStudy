// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonResponse _$CommonResponseFromJson(Map<String, dynamic> json) =>
    CommonResponse(
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      isStudent: json['isStudent'] as bool,
    );

Map<String, dynamic> _$CommonResponseToJson(CommonResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'isStudent': instance.isStudent,
    };
