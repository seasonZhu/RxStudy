import 'package:flutter_module/base/base_refresh_controller.dart';
import 'package:flutter_module/enum/response_status.dart';
import 'package:flutter_module/entity/article_info_entity.dart';
import 'package:flutter_module/enum/scroll_view_action_type.dart';
import 'package:flutter_module/enum/tag_type.dart';
import 'package:flutter_module/pages/tree/repository/tab_list_repository.dart';

class TabListController
    extends BaseRefreshController<TabListRepository, ArticleInfoDatas> {
  late TagType tagType;

  late String id;

  @override
  Future<void> onRefresh() async {
    page = initPage;
    await aRequest(type: ScrollViewActionType.refresh);
  }

  @override
  Future<void> onLoadMore() async {
    page = page + 1;
    await aRequest(type: ScrollViewActionType.loadMore);
  }

  @override
  Future<void> aRequest({
    required ScrollViewActionType type,
    Map<String, dynamic>? parameters,
  }) async {
    response = await request
        .getList(page: page, id: id, tagType: tagType)
        .catchError((error) {
      return processError(type: type, error: error);
    });
    status = response?.responseStatus ?? ResponseStatus.loading;

    final models = response?.data?.dataSource ?? [];

    switch (type) {
      case ScrollViewActionType.refresh:
        dataSource.clear();
        dataSource.addAll(models);
        break;
      case ScrollViewActionType.loadMore:
        dataSource.addAll(models);
        break;
    }

    refreshControllerStatusUpdate(type);

    update();
  }
}
