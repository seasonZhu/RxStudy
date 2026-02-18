import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GetBindWidget can bind GetxController, and when the page is disposed,
/// it can automatically destroy the bound related GetXController
///
///
/// Sample:
///
/// class SampleController extends GetxController {
///   final String title = 'My Awesome View';
/// }
///
/// class SamplePage extends StatelessWidget {
///   final controller = Get.put(SampleController());
///
///   @override
///   Widget build(BuildContext context) {
///     return GetBindWidget(
///       bind: controller,
///       child: Container(),
///     );
///   }
/// }
class GetBindWidget extends StatefulWidget {
  const GetBindWidget({
    Key? key,
    this.bind,
    this.tag,
    this.binds,
    this.tags,
    required this.child,
  })  : assert(
          binds == null || tags == null || binds.length == tags.length,
          'The binds and tags arrays length should be equal\n'
          'and the elements in the two arrays correspond one-to-one',
        ),
        super(key: key);

  final GetxController? bind;
  final String? tag;

  final List<GetxController>? binds;
  final List<String>? tags;

  final Widget child;

  @override
  State<GetBindWidget> createState() => _GetBindWidgetState();
}

class _GetBindWidgetState extends State<GetBindWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _closeGetXController();
    _closeGetXControllers();

    super.dispose();
  }

  ///Close GetxController bound to the current page
  void _closeGetXController() {
    if (widget.bind == null) {
      return;
    }

    final key = widget.bind.runtimeType.toString() + (widget.tag ?? '');
    GetInstance().delete(key: key);
  }

  ///Batch close GetxController bound to the current page
  void _closeGetXControllers() {
    if (widget.binds == null) {
      return;
    }

    for (var i = 0; i < widget.binds!.length; i++) {
      final type = widget.binds![i].runtimeType.toString();

      if (widget.tags == null) {
        GetInstance().delete(key: type);
      } else {
        final key = type + (widget.tags?[i] ?? '');
        GetInstance().delete(key: key);
      }
    }
  }
}

/*
/// 回收单个GetXController
class TestPage extends StatelessWidget {
  final logic = Get.put(TestLogic());

  @override
  Widget build(BuildContext context) {
    return GetBindWidget(
      bind: logic,
      child: Container(),
    );
  }
}

/// 回收多个GetXController
class TestPage extends StatelessWidget {
  final logicOne = Get.put(TestLogic(), tag: 'one');
  final logicTwo = Get.put(TestLogic());
  final logicThree = Get.put(TestLogic(), tag: 'three');

  @override
  Widget build(BuildContext context) {
    return GetBindWidget(
      binds: [logicOne, logicTwo, logicThree],
      tags: ['one', '', 'three'],
      child: Container(),
    );
  }
}

作者：小呆呆666
链接：https://juejin.cn/post/6924104248275763208
来源：稀土掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
*/

class AutoDisposePage extends StatefulWidget {
  const AutoDisposePage({Key? key}) : super(key: key);

  @override
  State<AutoDisposePage> createState() => _AutoDisposePageState();
}

class _AutoDisposePageState extends State<AutoDisposePage> {
  final AutoDisposeLogic logic = Get.put(AutoDisposeLogic());

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    Get.delete<AutoDisposeLogic>();
    super.dispose();
  }
}

class AutoDisposeLogic extends GetxController {}
