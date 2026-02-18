import 'package:flutter_module/generated/json/base/json_convert_content.dart';

abstract class IEntity<T> {
  T? generateOBJ<O>(Object? json) {
    if (T.toString() == 'String') {
      return json.toString() as T;
    } else if (T.toString() == 'Map<dynamic, dynamic>') {
      return json as T;
    } else {
      /// List类型数据由fromJsonAsT判断处理
      return JsonConvert.fromJsonAsT<T>(json);
    }
  }
}
