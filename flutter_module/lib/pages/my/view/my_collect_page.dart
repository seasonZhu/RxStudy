import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_module/base/class_name.dart';
import 'package:flutter_module/pages/common/info_cell.dart';
import 'package:flutter_module/pages/common/status_view.dart';
import 'package:flutter_module/pages/my/controller/my_collect_controller.dart';
import 'package:flutter_module/routes/routes.dart';
import 'package:flutter_module/pages/common/refresh_header_footer.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

class MyCollectPage extends GetView<MyCollectController> {
  const MyCollectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("我的收藏"),
      ),
      child: StatusView<MyCollectController>(
        contentBuilder: (controller) {
          return SmartRefresher(
            enablePullUp: true,
            header: const RefreshHeader(),
            footer: const RefreshFooter(),
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoadMore,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controller.dataSource.length,
              separatorBuilder: (context, index) {
                return const Divider(
                  indent: 15,
                  endIndent: 15,
                  height: 0.1,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                final model = controller.dataSource[index];
                return Slidable(
                  // Specify a key if the Slidable is dismissible.
                  key: Key(model.title.toString()),
                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.3,
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          controller.unCollectAction(index: index);
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '取消收藏',
                      ),
                    ],
                  ),
                  // The child of the Slidable is what the user sees when the
                  // component is not dragged.
                  child: InfoCell(
                    model: model,
                    callback: (_) => Get.toNamed(Routes.web,
                        arguments: model,
                        parameters: {"className": className(this)}),
                    isNeedBottomLine: false,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void doNothing(BuildContext context) {}
}
