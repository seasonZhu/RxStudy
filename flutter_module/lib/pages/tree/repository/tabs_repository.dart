import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/enum/tag_type.dart';
import 'package:flutter_module/entity/base_entity.dart';
import 'package:flutter_module/entity/tab_entity.dart';
import 'package:flutter_module/http_util/request.dart' as http;

class TabsRepository extends IRepository {
  TabsRepository(this.type);

  TagType type;

  Future<BaseEntity<List<TabEntity>>> getTab() =>
      http.Request.get(api: type.tabApi);
}
