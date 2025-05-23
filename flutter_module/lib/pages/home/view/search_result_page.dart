import 'package:flutter/cupertino.dart';

import 'package:flutter_module/pages/common/info_cell.dart';
import 'package:flutter_module/pages/common/refresh_header_footer.dart';
import 'package:flutter_module/pages/common/status_view.dart';
import 'package:flutter_module/pages/home/controller/search_result_controller.dart';
import 'package:flutter_module/routes/routes.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';

class SearchResultPage extends GetView<SearchResultController> {
  const SearchResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = Get.arguments;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: StatusView<SearchResultController>(
        contentBuilder: (_) {
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
                return InfoCell(
                  model: model,
                  callback: (_) => Get.toNamed(Routes.web, arguments: model),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
