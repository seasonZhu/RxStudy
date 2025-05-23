import 'package:flutter/material.dart';

import 'package:lpinyin/lpinyin.dart';

import 'package:flutter_module/entity/tab_entity.dart';

class TreeCell extends StatelessWidget {
  const TreeCell(this.model, {Key? key}) : super(key: key);

  final TabEntity model;

  static const space = SizedBox(
    height: 10,
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.33, color: Colors.grey[400]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _chipTitleItem(model),
        ),
      ),
    );
  }

  List<Widget> _chipTitleItem(TabEntity model) {
    final list = <Widget>[];

    // 从这里看出,final已经非常接近let了
    final text = Text(
      model.name.toString(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    final wrap = Wrap(
      children: (model.children ?? [])
          .map(
            (topic) => Padding(
              padding: const EdgeInsets.all(3.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: _getChipBgColor(topic.name.toString()),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    topic.name.toString(),
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );

    list
      ..add(text)
      ..add(space)
      ..add(wrap);
    return list;
  }

  Color _getChipBgColor(String name) {
    String pinyin = PinyinHelper.getFirstWordPinyin(name);
    pinyin = pinyin.substring(0, 1).toUpperCase();
    return _nameToColor(pinyin);
  }

  Color _nameToColor(String name) {
    final int hash = name.hashCode & 0xffff;
    final double hue = (360.0 * hash / (1 << 15)) % 360.0;
    return HSVColor.fromAHSV(1.0, hue, 0.4, 0.90).toColor();
  }
}
