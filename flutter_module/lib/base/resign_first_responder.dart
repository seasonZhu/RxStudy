import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class ResignFirstResponder {
  ResignFirstResponder._();

  /// 此方法需要获取当前Widget的上下文,而且用起来也不够安全
  static of(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// 推荐下面的方法
  static unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static hideKeyboard() {
    SystemChannels.textInput.invokeMethod("TextInput.hide");
  }
}
