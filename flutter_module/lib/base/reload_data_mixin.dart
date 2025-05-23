import 'package:flutter/material.dart';

mixin ReloadDataMixin<T extends StatefulWidget> on State<T> {

  void reloadData() {
    if (mounted) setState(() {});
  }
}