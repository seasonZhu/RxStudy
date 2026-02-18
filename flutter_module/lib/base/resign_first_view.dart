import 'package:flutter/material.dart';

import 'resign_first_responder.dart';

class ResignFirstView extends StatelessWidget {
  const ResignFirstView({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ResignFirstResponder.unfocus();
      },
      child: child,
    );
  }
}
