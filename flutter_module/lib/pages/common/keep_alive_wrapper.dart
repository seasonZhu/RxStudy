import 'package:flutter/material.dart';

class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({
    Key? key,
    this.keepAlive = true,
    required this.child,
  }) : super(key: key);
  final bool keepAlive;
  final Widget child;
 
  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}
 
class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
 
  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    if(oldWidget.keepAlive != widget.keepAlive) {
      // keepAlive 状态需要更新，实现在 AutomaticKeepAliveClientMixin 中
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }
 
  @override
  bool get wantKeepAlive => widget.keepAlive;
}

/**
 封装了一个 KeepAliveWrapper 组件，
 如果哪个列表项需要缓存，只需要使用 KeepAliveWrapper 包裹一下它即可。

 @override
Widget build(BuildContext context) {
  var children = <Widget>[];
  for (int i = 0; i < 10++i) {
    //只需要用 KeepAliveWrapper 包装一下即可
    children.add(KeepAliveWrapper(child:Page( text: '$i'));
  }
  return PageView(children: children);
}
 */