import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final VoidCallback? retryAction;

  const ErrorView({Key? key, this.retryAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '哎呀,出错了...',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 44,
            ),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  onPressed: () {
                    if (retryAction != null) {
                      retryAction!();
                    }
                  },
                  child: const Text(
                    "重试",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
