import 'package:flutter/material.dart';

/// 悬浮框管理器
class SmallWindowManager {
  static final SmallWindowManager _instance = SmallWindowManager._();

  factory SmallWindowManager() => _instance;

  SmallWindowManager._();

  ///浮窗
  OverlayEntry? overlayEntry;

  show(BuildContext context) {
    if (overlayEntry == null) {
      overlayEntry = OverlayEntry(builder: (BuildContext context) {
        return SmallWindowWidget(
          top: 160,
          left: 279,
          child: GestureDetector(
            onTap: () {
              hide();
            },
            child: Material(
              child: Container(
                color: Colors.red,
                width: 100,
                height: 200,
                child: const Center(
                  child: Text("small"),
                ),
              ),
            ),
          ),
        );
      });
      Overlay.of(context).insert(overlayEntry!);
    }
  }

  ///关闭小窗
  void hide() {
    overlayEntry?.remove();
    overlayEntry = null;
  }
}

class SmallWindowWidget extends StatefulWidget {
  final Duration duration;
  final Widget child;
  final double top;
  final double left;

  const SmallWindowWidget({
    super.key,
    this.duration = const Duration(milliseconds: 100),
    required this.child,
    required this.top,
    required this.left,
  });

  @override
  State<SmallWindowWidget> createState() => _SmallWindowWidgetState();
}

class _SmallWindowWidgetState extends State<SmallWindowWidget> with TickerProviderStateMixin {
  AnimationController? _controller;
  double left = 0;
  double top = 0;

  double maxX = 0;
  double maxY = 0;

  var parentKey = GlobalKey();
  var childKey = GlobalKey();

  var parentSize = const Size(0, 0);
  var childSize = const Size(0, 0);

  @override
  void initState() {
    left = widget.left;
    top = widget.top;
    WidgetsBinding.instance.addPostFrameCallback((d) {
      parentSize = getWidgetSize(parentKey);
      childSize = getWidgetSize(childKey);
      maxX = parentSize.width - childSize.width;
      maxY = parentSize.height - childSize.height;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: parentKey,
      fit: StackFit.expand,
      children: [
        Positioned(
          key: childKey,
          left: left,
          top: top,
          child: GestureDetector(
            onPanUpdate: (d) {
              var delta = d.delta;
              left += delta.dx;
              top += delta.dy;
              setState(() {});
            },
            onPanEnd: (d) {
              left = getValue(left, maxX);
              top = getValue(top, maxY);
              adsorb();
            },
            child: widget.child,
          ),
        )
      ],
    );
  }

  ///限制边界
  double getValue(double value, double max) {
    if (value < 0) {
      return 0;
    } else if (value > max) {
      return max;
    } else {
      return value;
    }
  }

  ///吸附
  void adsorb() {
    bool isLeft = (left + childSize.width / 2) < parentSize.width / 2;
    _controller = AnimationController(vsync: this)..duration = widget.duration;
    var animation = Tween<double>(begin: left, end: isLeft ? 0 : maxX).animate(_controller!);
    animation.addListener(() {
      left = animation.value;
      setState(() {});
    });
    _controller!.forward();
  }

  Size getWidgetSize(GlobalKey key) {
    final RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
    return renderBox.size;
  }
}
