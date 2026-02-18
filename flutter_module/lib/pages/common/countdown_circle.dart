import 'dart:async';
import 'package:flutter/material.dart';

class CountdownCircle extends StatefulWidget {
  const CountdownCircle({
    Key? key,
    this.countdownSeconds = 5,
    this.ringBackgroundColor = Colors.transparent,
    this.ringColor = Colors.white,
    this.ringStrokeWidth = 3.0,
    this.text = "跳过",
    this.textStyle = const TextStyle(color: Colors.grey),
    this.finished,
  })  : assert(countdownSeconds > 0),
        assert(ringStrokeWidth > 0),
        super(key: key);

  /// 倒计时秒数，默认为 5 秒
  final int countdownSeconds;

  /// 圆环的背景色，ringColor 会逐渐填充背景色，默认为透明色
  final Color ringBackgroundColor;

  /// 圆环逐渐填充的颜色，默认为 Colors.deepOrange
  final Color ringColor;

  /// 圆环的宽度，默认为3.0
  final double ringStrokeWidth;

  /// 跳过文字
  final String text;

  /// 中间文案的字体
  final TextStyle textStyle;

  /// 点击或倒计时结束后的回调
  /// [byUserClick] 为 true，是用户点击，否则是倒计时结束
  final void Function(bool)? finished;

  @override
  State<CountdownCircle> createState() => _CountdownCircleState();
}

class _CountdownCircleState extends State<CountdownCircle> {
  Timer? _timer;
  final _currentTimer = ValueNotifier<int>(0);
  final _isVisible = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _currentTimer.value += 10;
      if (_currentTimer.value >= widget.countdownSeconds * 1000) {
        _didFinished(byUserClick: false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (context, bool isVisible, child) {
        return Visibility(
          visible: isVisible,
          child: GestureDetector(
            onTap: () => _didFinished(byUserClick: true),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ValueListenableBuilder(
                  builder: ((context, int countdownDuration, child) =>
                      CircularProgressIndicator(
                        strokeWidth: widget.ringStrokeWidth,
                        color: widget.ringColor,
                        value: countdownDuration /
                            (widget.countdownSeconds * 1000),
                        backgroundColor: widget.ringBackgroundColor,
                      )),
                  valueListenable: _currentTimer,
                ),
                Text(
                  widget.text,
                  style: widget.textStyle,
                ),
              ],
            ),
          ),
        );
      },
      valueListenable: _isVisible,
    );
  }

  void _didFinished({required bool byUserClick}) {
    if (widget.finished != null) {
      widget.finished!(byUserClick);
    }
    _timer?.cancel();
    _isVisible.value = false;
  }
}
