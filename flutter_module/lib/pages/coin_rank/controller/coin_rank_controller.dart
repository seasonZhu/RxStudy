import 'package:get/get.dart';

import 'package:flutter_module/base/base_refresh_controller.dart';
import 'package:flutter_module/enum/response_status.dart';
import 'package:flutter_module/entity/coin_rank_entity.dart';
import 'package:flutter_module/base/class_name.dart';
import 'package:flutter_module/pages/coin_rank/repository/coin_rank_repository.dart';
import 'package:flutter_module/enum/scroll_view_action_type.dart';

class CoinRankController
    extends BaseRefreshController<CoinRankRepository, CoinRankDatas> {
  @override
  void onInit() {
    super.onInit();
    initPage = Get.find<int>(tag: className(CoinRankController));
    page = initPage;
    refreshController = Get.find(tag: className(CoinRankController));
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
    response = await request.getCoinRankList(page).catchError((error) {
      return processError(type: type, error: error);
    });

    /// 正常场景
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
