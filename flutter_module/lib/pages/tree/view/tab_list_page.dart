import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';
import 'package:flutter_module/pages/common/empty_view.dart';
import 'package:flutter_module/pages/common/refresh_header_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:flutter_module/pages/tree/controller/tab_list_controller.dart';
import 'package:flutter_module/pages/common/info_cell.dart';
import 'package:flutter_module/routes/routes.dart';

class TabListPage extends StatelessWidget {
  final TabListController _controller;

  const TabListPage({Key? key, required TabListController controller})
      : _controller = controller,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TabListController>(
      tag: _controller.id,
      builder: ((controller) {
        return SmartRefresher(
          enablePullUp: true,
          header: const RefreshHeader(),
          footer: const RefreshFooter(),
          controller: controller.refreshController,
          onRefresh: controller.onRefresh,
          onLoading: controller.onLoadMore,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: controller.dataSource.length,
            itemBuilder: (BuildContext context, int index) {
              if (controller.dataSource.isEmpty) {
                return const EmptyView();
              }

              final model = controller.dataSource[index];
              return InfoCell(
                model: model,
                callback: (_) {
                  Get.toNamed(Routes.web, arguments: model);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
