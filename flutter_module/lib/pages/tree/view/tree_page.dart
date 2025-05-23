import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import 'package:flutter_module/enum/tag_type.dart';
import 'package:flutter_module/pages/common/status_view.dart';
import 'package:flutter_module/pages/tree/controller/tabs_controller.dart';
import 'tree_cell.dart';

class TreePage extends GetView<TabsController> {
  const TreePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("体系"),
      ),
      child: StatusView<TabsController>(
        tag: TagType.tree.toString(),
        contentBuilder: (controller) {
          return ListView.builder(
            /// 通过ScrollMixin的scoll,可以监听滑动到顶部与滑动到底部,
            /// 这里添加了ScrollMixin的scoll之后,iOS特有的点击顶部回到列表顶部就失效了
            controller: controller.scroll,
            shrinkWrap: true,
            itemCount: controller.data?.length ?? 0,
            itemBuilder: ((context, index) {
              final model = controller.data?[index];
              if (model != null) {
                return TreeCell(model);
              } else {
                return Container();
              }
            }),
          );
        },
      ),
    );
  }
}
