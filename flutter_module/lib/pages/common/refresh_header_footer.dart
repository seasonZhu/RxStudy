import 'package:flutter/cupertino.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshHeader extends StatelessWidget {
  const RefreshHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const WaterDropHeader(
      complete: Center(
        child: Text("下拉刷新完成"),
      ),
    );
  }
}

class RefreshFooter extends StatelessWidget {
  const RefreshFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (context, mode) {
        return Center(child: mode?.statusBody);
      },
    );
  }
}

extension on LoadStatus {
  Widget get statusBody {
    switch (this) {
      case LoadStatus.idle:
        return const Text("上拉加载");
      case LoadStatus.canLoading:
        return const Text("松手,加载更多!");
      case LoadStatus.loading:
        return const CupertinoActivityIndicator();
      case LoadStatus.noMore:
        return const Text("没有更多数据了!");
      case LoadStatus.failed:
        return Container();
    }
  }
}
