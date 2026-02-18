import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_module/extension/theme_data_extension.dart';
import 'package:flutter_module/base/resign_first_responder.dart';
import 'package:flutter_module/logger/logger.dart';

class SearchTextField extends StatelessWidget {
  final searchKeyCtrl = TextEditingController(text: '');

  final ValueChanged<String> _keywordCallback;

  final changeString = "".obs;

  SearchTextField({Key? key, required ValueChanged<String> keywordCallback})
      : _keywordCallback = keywordCallback,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: CupertinoTextField(
            style: TextStyle(color: Theme.of(context).brightness.color),
            keyboardType: TextInputType.text,
            controller: searchKeyCtrl,
            placeholder: "请输入搜索关键字",
            onEditingComplete: () {
              _inputComplete(context);
            },
            onSubmitted: (input) {
              logger.d(input);
            },
            onChanged: (value) {
              changeString.value = value;
            },
          ),
        ),
        Obx(
          (() {
            return Visibility(
              visible: changeString.isNotEmpty,
              child: InkWell(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 50,
                  height: 30,
                  alignment: Alignment.center,
                  child: const Text(
                    '搜索',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () {
                  _inputComplete(context);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _inputComplete(BuildContext context) {
    ResignFirstResponder.unfocus();
    // if (searchKeyCtrl.text.trim().isEmpty) {
    //   Get.snackbar('', '搜索关键字不能为空');
    //   return;
    // }
    _keywordCallback(searchKeyCtrl.text.trim());
  }
}

/// Obx与ObxValue的使用区别
class SearchValueField extends StatelessWidget {
  final _searchKeyCtrl = TextEditingController(text: '');

  final ValueChanged<String> _keywordCallback;

  SearchValueField({Key? key, required ValueChanged<String> keywordCallback})
      : _keywordCallback = keywordCallback,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ObxValue<RxBool>(
      (visibleRelay) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: CupertinoTextField(
                style: TextStyle(color: Theme.of(context).brightness.color),
                keyboardType: TextInputType.text,
                controller: _searchKeyCtrl,
                placeholder: "请输入搜索关键字",
                onEditingComplete: () {
                  _inputComplete(context);
                },
                onSubmitted: (input) {
                  logger.d(input);
                },
                onChanged: (value) {
                  visibleRelay.value = value.isNotEmpty;
                },
              ),
            ),
            Visibility(
              visible: visibleRelay.value,
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  // width: 50,
                  // height: 30,
                  alignment: Alignment.center,
                  child: const Text(
                    '搜索',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onTap: () {
                  _inputComplete(context);
                },
              ),
            ),
          ],
        );
      },
      false.obs,
    );
  }

  void _inputComplete(BuildContext context) {
    ResignFirstResponder.unfocus();
    _keywordCallback(_searchKeyCtrl.text.trim());
  }
}
