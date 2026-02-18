import 'dart:async';
import 'package:flutter/material.dart';

//import 'package:marquee_flutter/marquee_flutter.dart'; 参考这个写的,改了一些

/// 没有使用
class MarqueeLabel extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;

  ///滚动方向，水平或者垂直
  final Axis scrollAxis;

  ///空白部分占控件的百分比 默认是0.1
  final double ratioOfBlankToScreen;

  const MarqueeLabel({
    Key? key,
    required this.text,
    this.textStyle,
    this.scrollAxis = Axis.horizontal,
    this.ratioOfBlankToScreen = 0.1,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MarqueeLabelState();
  }
}

class MarqueeLabelState extends State<MarqueeLabel>
    with SingleTickerProviderStateMixin {
  late ScrollController scrollController;
  late double screenWidth;
  late double screenHeight;
  double position = 0.0;
  late Timer timer;
  final double _moveDistance = 3.0;
  final int _timerRest = 100;
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(
      (callback) {
        startTimer();
      },
    );
  }

  void startTimer() {
    double widgetWidth =
        _key.currentContext?.findRenderObject()?.paintBounds.size.width ?? 0;
    double widgetHeight =
        _key.currentContext?.findRenderObject()?.paintBounds.size.height ?? 0;

    timer = Timer.periodic(
      Duration(milliseconds: _timerRest),
      (timer) {
        double maxScrollExtent = scrollController.position.maxScrollExtent;
        double pixels = scrollController.position.pixels;
        if (pixels + _moveDistance >= maxScrollExtent) {
          if (widget.scrollAxis == Axis.horizontal) {
            position = (maxScrollExtent -
                        screenWidth * widget.ratioOfBlankToScreen +
                        widgetWidth) /
                    2 -
                widgetWidth +
                pixels -
                maxScrollExtent;
          } else {
            position = (maxScrollExtent -
                        screenHeight * widget.ratioOfBlankToScreen +
                        widgetHeight) /
                    2 -
                widgetHeight +
                pixels -
                maxScrollExtent;
          }
          scrollController.jumpTo(position);
        }
        position += _moveDistance;
        scrollController.animateTo(position,
            duration: Duration(milliseconds: _timerRest), curve: Curves.linear);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: _key,
      scrollDirection: widget.scrollAxis,
      controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(widget.text),
    );
  }
}
