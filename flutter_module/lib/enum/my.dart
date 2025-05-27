import 'package:flutter/material.dart';
import 'package:flutter_module/base/interface.dart';
import 'package:flutter_module/routes/routes.dart';

enum My {
  header,
  ranking,
  myGitHub,
  myJueJin,
  myCoin,
  myCollect,
  themeSetting,
  toNative,
  login,
  logout;
}

extension Extension on My {
  String get title {
    switch (this) {
      case My.header:
        return "";
      case My.ranking:
        return "积分排名";
      case My.myGitHub:
        return "我的GitHub";
      case My.myJueJin:
        return "我的掘金";
      case My.myCoin:
        return "我的积分";
      case My.myCollect:
        return "我的收藏";
      case My.themeSetting:
        return "主题颜色";
      case My.toNative:
        return "返回Native";
      case My.login:
        return "登录";
      case My.logout:
        return "登出";
    }
  }

  String get path {
    switch (this) {
      case My.header:
        return "";
      case My.ranking:
        return Routes.coinRink;
      case My.myGitHub:
        return Routes.web;
      case My.myJueJin:
        return Routes.web;
      case My.myCoin:
        return Routes.myCoinHistory;
      case My.myCollect:
        return Routes.myCollect;
      case My.themeSetting:
        return Routes.themeSetting;
      case My.toNative:
        return Routes.unknown;
      case My.login:
        return Routes.login;
      case My.logout:
        return Routes.unknown;
    }
  }

  WebLoadInfoEntity? get entity {
    if (this == My.myJueJin) {
      return WebLoadInfoEntity(
          "我的掘金", "https://juejin.cn/user/4353721778057997");
    } else if (this == My.myGitHub) {
      return WebLoadInfoEntity("我的GitHub", "https://github.com/seasonZhu");
    } else {
      return null;
    }
  }

  IconData get icon {
    switch (this) {
      case My.header:
        return Icons.usb;
      case My.ranking:
        return Icons.poll;
      case My.myGitHub:
        return Icons.link;
      case My.myJueJin:
        return Icons.looks;
      case My.myCoin:
        return Icons.trending_up;
      case My.myCollect:
        return Icons.local_offer;
      case My.themeSetting:
        return Icons.color_lens;
      case My.toNative:
        return Icons.apple;
      case My.login:
        return Icons.login;
      case My.logout:
        return Icons.logout;
    }
  }

  static final visitorDataSource = [
    My.header,
    My.myGitHub,
    My.myJueJin,
    My.ranking,
    My.themeSetting,
    My.toNative,
    My.login,
  ];

  static final userDataSource = [
    My.header,
    My.myGitHub,
    My.myJueJin,
    My.ranking,
    My.myCoin,
    My.myCollect,
    My.themeSetting,
    My.toNative,
    My.logout,
  ];
}

class WebLoadInfoEntity implements IWebLoadInfo {
  WebLoadInfoEntity(this.title, this.link);
  @override
  int? id;
  @override
  int? originId;
  @override
  String? title;
  @override
  String? link;
}
