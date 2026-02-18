import 'package:flutter/material.dart';

/*
比 Flutter ListView 更灵活的布局方式
链接：https://juejin.cn/post/7184955986224873531
*/
class MyListView extends ScrollView {
  const MyListView(
      {Key? key,
      this.banner,
      required this.itemBuilder,
      required this.itemCount,
      this.itemExtent,
      Key? center})
      : super(key: key, center: center);

  final Widget? banner;
  final IndexedWidgetBuilder itemBuilder;
  final double? itemExtent;
  final int itemCount;

  @override
  List<Widget> buildSlivers(BuildContext context) {
    List<Widget> list = [];
    if (banner != null) {
      list.add(SliverToBoxAdapter(child: banner!));
    }
    if (center == null) {
      if (itemExtent == null) {
        list.add(
          SliverList(
            delegate:
                SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
          ),
        );
      } else {
        list.add(
          SliverFixedExtentList(
            delegate:
                SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
            itemExtent: itemExtent!,
          ),
        );
      }
    } else {
      for (var i = 0; i < itemCount; i++) {
        list.add(
          SliverToBoxAdapter(
            key: ValueKey(i),
            child: itemBuilder(context, i),
          ),
        );
      }
    }
    return list;
  }
}

