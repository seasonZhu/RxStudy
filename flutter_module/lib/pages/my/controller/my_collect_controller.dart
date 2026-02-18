import 'package:get/get.dart';

import 'package:flutter_module/base/base_refresh_controller.dart';
import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/enum/response_status.dart';
import 'package:flutter_module/entity/article_info_entity.dart';
import 'package:flutter_module/base/class_name.dart';
import 'package:flutter_module/pages/my/repository/my_collect_repository.dart';
import 'package:flutter_module/enum/scroll_view_action_type.dart';
import 'package:flutter_module/app_service/account_service.dart';

class MyCollectController
    extends BaseRefreshController<MyCollectRepository, ArticleInfoDatas> {
  @override
  void onInit() {
    super.onInit();
    initPage = Get.find(tag: className(MyCollectController));
    page = initPage;
    refreshController = Get.find(tag: className(MyCollectController));
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
    response =
        await request.getCollectArticleList(page: page).catchError((error) {
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

  Future<void> unCollectAction({required int index}) async {
    final model = await request.unCollectAction(
        originId: dataSource[index].originId ?? 0);

    String message;
    if (model.isSuccess) {
      if ((AccountService.find.info?.collectIds ?? [])
          .contains(dataSource[index].originId)) {
        (AccountService.find.info?.collectIds ?? [])
            .remove(dataSource[index].originId);
      }
      dataSource.removeAt(index);
      message = "取消收藏成功";
    } else {
      message = model.errorMsg.toString();
    }

    Get.snackbar(
      "",
      message,
      duration: const Duration(seconds: 1),
    );

    update();
  }

  void removeUnCollectItem(IWebLoadInfo webLoadInfo) {
    final data =
        dataSource.firstWhere((element) => element.link == webLoadInfo.link);
    dataSource.remove(data);

    update();
  }
}
