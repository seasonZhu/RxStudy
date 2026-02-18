import 'package:flutter_module/http_util/api.dart';

enum TagType {
  project,
  publicNumber,
  tree;
}

extension Ext on TagType {
  String get title {
    switch (this) {
      case TagType.project:
        return "项目";
      case TagType.publicNumber:
        return "公众号";
      case TagType.tree:
        return "体系";
    }
  }

  int get pageNum {
    switch (this) {
      case TagType.project:
        return 1;
      case TagType.publicNumber:
        return 1;
      case TagType.tree:
        return 0;
    }
  }

  String get tabApi {
    switch (this) {
      case TagType.project:
        return Api.getProjectClassify;
      case TagType.publicNumber:
        return Api.getPublicNumber;
      case TagType.tree:
        return Api.getTree;
    }
  }

  String get detailApi {
    switch (this) {
      case TagType.project:
        return Api.getProjectClassifyList;
      case TagType.publicNumber:
        return Api.getPublicNumberList;
      case TagType.tree:
        return Api.getTreeDetailList;
    }
  }
}
