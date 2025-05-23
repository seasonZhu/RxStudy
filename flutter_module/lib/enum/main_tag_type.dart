import 'package:flutter/material.dart';
import 'package:flutter_module/enum/tag_type.dart';

import 'package:flutter_module/pages/home/view/home_page.dart';
import 'package:flutter_module/pages/my/view/my_page.dart';
import 'package:flutter_module/pages/tree/view/tabs_page.dart';
import 'package:flutter_module/pages/tree/view/tree_page.dart';

enum MainTagType {
  home,
  project,
  publicNumber,
  tree,
  my;
}

extension MainTagTypeExt on MainTagType {
  IconData get icon {
    switch (this) {
      case MainTagType.home:
        return Icons.home;
      case MainTagType.project:
        return Icons.web;
      case MainTagType.publicNumber:
        return Icons.public;
      case MainTagType.tree:
        return Icons.list;
      case MainTagType.my:
        return Icons.person;
    }
  }

  String get title {
    switch (this) {
      case MainTagType.home:
        return "首页";
      case MainTagType.project:
        return "项目";
      case MainTagType.publicNumber:
        return "公众号";
      case MainTagType.tree:
        return "体系";
      case MainTagType.my:
        return "我的";
    }
  }

  Widget get page {
    switch (this) {
      case MainTagType.home:
        return const HomePage();
      case MainTagType.project:
        return const TabsPage(type: TagType.project);
      case MainTagType.publicNumber:
        return const TabsPage(type: TagType.publicNumber);
      case MainTagType.tree:
        return const TreePage();
      case MainTagType.my:
        return const MyPage();
    }
  }

  static List<BottomNavigationBarItem> get items {
    return MainTagType.values
        .map(
          (type) => BottomNavigationBarItem(
            icon: Icon(type.icon),
            label: type.title,
          ),
        )
        .toList();
  }
}
