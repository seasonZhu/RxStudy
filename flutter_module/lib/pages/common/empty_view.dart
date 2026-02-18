import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final VoidCallback? emptyTap;

  const EmptyView({Key? key, this.emptyTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (emptyTap != null) {
                  emptyTap!();
                }
              },
              child: const Text(
                '暂无数据',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
