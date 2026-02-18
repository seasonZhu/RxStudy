import 'package:get/get.dart';

import 'package:flutter_module/base/base_refresh_controller.dart';
import 'package:flutter_module/enum/response_status.dart';
import 'package:flutter_module/entity/article_info_entity.dart';
import 'package:flutter_module/base/class_name.dart';
import 'package:flutter_module/pages/home/repository/search_result_repository.dart';
import 'package:flutter_module/enum/scroll_view_action_type.dart';

class SearchResultController
    extends BaseRefreshController<SearchResultRepository, ArticleInfoDatas> {
  @override
  void onInit() {
    super.onInit();
    initPage = Get.find(tag: className(SearchResultController));
    page = initPage;
    refreshController = Get.find(tag: className(SearchResultController));
  }

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
    String keyword = Get.arguments;

    response = await request
        .searchKeyword(page: page, keyword: keyword)
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
