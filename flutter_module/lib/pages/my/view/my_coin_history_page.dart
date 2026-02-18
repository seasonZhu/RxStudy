import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_module/pages/common/status_view.dart';
import 'package:flutter_module/pages/my/controller/my_coin_history_controller.dart';
import 'package:flutter_module/routes/routes.dart';
import 'package:flutter_module/pages/common/refresh_header_footer.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

class MyCoinHistoryPage extends GetView<MyCoinHistoryController> {
  const MyCoinHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("我的积分"),
      ),
      child: StatusView<MyCoinHistoryController>(
        contentBuilder: (controller) {
          return SmartRefresher(
            enablePullUp: true,
            header: const RefreshHeader(),
            footer: const RefreshFooter(),
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoadMore,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.dataSource.length,
              itemBuilder: (BuildContext context, int index) {
                final model = controller.dataSource[index];

                return ListTile(
                  leading: Text(model.reason.toString()),
                  title: Text(model.desc.toString()),
                  trailing: Text(model.coinCount.toString()),
                  onTap: () => Get.toNamed(Routes.stateMixinExample),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
