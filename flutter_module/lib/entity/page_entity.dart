import 'package:flutter_module/entity/i_entity.dart';
import 'package:flutter_module/resource/constant.dart';

/// 有关与BaseEntity<PageEntity<CoinRankDatas>>这种泛型解析我还没有找个非常好的方案,目前还是保证单层解析
class PageEntity<T> extends IEntity<T> {
  int? curPage;
  T? dataSource;
  int? offset;
  bool? over;
  int? pageCount;
  int? size;
  int? total;

  PageEntity.fromJson(Map<String, dynamic> json) {
    curPage = json[Constant.curPage] as int?;
    offset = json[Constant.offset] as int?;
    over = json[Constant.over] as bool?;
    pageCount = json[Constant.pageCount] as int?;
    size = json[Constant.size] as int?;
    total = json[Constant.total] as int?;
    if (json.containsKey(Constant.datas)) {
      dataSource = generateOBJ<T>(json[Constant.datas] as Object);
    }
  }
}
