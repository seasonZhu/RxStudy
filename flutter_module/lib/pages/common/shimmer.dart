import 'package:flutter/material.dart';

// Most Basic Shimmer
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    this.width,
    this.height,
    this.minOpacity = 0.015,
    this.maxOpacity = 0.15,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.child,
  });

  final double? width;
  final double? height;
  final double minOpacity;
  final double maxOpacity;
  final BorderRadius? borderRadius;
  final Widget? child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: widget.minOpacity,
      upperBound: widget.maxOpacity,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: controller,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
