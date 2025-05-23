import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/entity/base_entity.dart';
import 'package:flutter_module/entity/hot_key_entity.dart';
import 'package:flutter_module/http_util/request.dart' as http;
import 'package:flutter_module/http_util/api.dart';

class HotKeyRepository extends IRepository {
  Future<BaseEntity<List<HotKeyEntity>>> getHotKey() =>
      http.Request.get(api: Api.getSearchHotKey);
}
