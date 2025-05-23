import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_module/app_service/theme_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:flutter_module/enum/tag_type.dart';
import 'package:flutter_module/extension/string_extension.dart';
import 'package:flutter_module/pages/common/status_view.dart';
import 'package:flutter_module/pages/common/keep_alive_wrapper.dart';
import 'package:flutter_module/pages/tree/controller/tab_list_controller.dart';
import 'package:flutter_module/pages/tree/controller/tabs_controller.dart';
import 'package:flutter_module/pages/tree/view/tab_list_page.dart';

class TabsPage extends StatefulWidget {
  final TagType type;

  const TabsPage({Key? key, required this.type}) : super(key: key);

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabsController _tabsController;

  late TabController _tabController;

  late ThemeService _themeService;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabsController = Get.find<TabsController>(tag: widget.type.toString());
    _themeService = ThemeService.find;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CupertinoPageScaffold(
      child: StatusView<TabsController>(
        tag: widget.type.toString(),
        contentBuilder: (controller) {
          _tabController =
              TabController(length: controller.data?.length ?? 0, vsync: this);
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: MaterialApp(
                home: _tabBar(_tabController),
                debugShowCheckedModeBanner: false,
              ), //_segmentedControl(), //Text(_tabsController.type.title),
              //bottom: _tabBar(_tabController),
            ),
            child: TabBarView(
              controller: _tabController,
              children: _createTabsPage(),
            ),
          );
        },
      ),
    );
  }

  TabBar _tabBar(TabController tabController) {
    return TabBar(
      tabs: (_tabsController.data ?? []).map(
        (model) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Text(model.name.toString().replaceHtmlElement),
            ),
          );
        },
      ).toList(),
      controller: tabController,
      isScrollable: true,
      // 底部线的颜色
      indicatorColor: _themeService.indicatorColor, //Colors.blue,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 18),
      // 选中tab的文字颜色
      labelColor: _themeService.labelColor, //Colors.black,
      unselectedLabelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      // 未选中tab的文字颜色
      unselectedLabelColor: _themeService.unselectedLabelColor, //Colors.grey,
      labelPadding: const EdgeInsets.all(0.0),
      indicatorPadding: const EdgeInsets.all(0.0),
      indicatorWeight: 2.3,
    );
  }

  List<Widget> _createTabsPage() {
    return (_tabsController.data ?? []).map((model) {
      final controller = TabListController();
      controller.tagType = _tabsController.type;
      controller.id = model.id.toString();
      controller.request = Get.find();
      controller.refreshController = RefreshController(initialRefresh: true);
      controller.page = _tabsController.type.pageNum;
      controller.initPage = _tabsController.type.pageNum;
      Get.put(controller, tag: model.id.toString());
      return KeepAliveWrapper(
        child: TabListPage(
          controller: controller,
        ),
      );
    }).toList();
  }

  Widget _segmentedControl() {
    final array = _tabsController.data ?? [];

    if (array.isEmpty) {
      return Container();
    }

    final map = <int, Widget>{};
    for (var i = 0; i < array.length; i++) {
      final model = array[i];
      final widget = Container(
        padding: const EdgeInsets.all(10),
        child: Text(model.name.toString().replaceHtmlElement),
      );
      map[i] = widget;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: CupertinoSegmentedControl<int>(
        groupValue: _tabController.animation?.value.toInt(),
        children: map,
        onValueChanged: ((value) {
          _tabController.animateTo(value);
        }),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
