import 'dart:async';

import 'package:flutter/material.dart';

class StreamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamExamplePage(),
    );
  }
}

class StreamExamplePage extends StatelessWidget {
  StreamExamplePage({Key? key}) : super(key: key);

  final _viewModel = StreamExampleViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RxDart编写计数器"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            StreamBuilder<int>(
              initialData: 0,
              stream: _viewModel.stream,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data.toString(),
                  //_viewModel.stream.value.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _viewModel.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StreamExampleViewModel {
  final _controller = StreamController<int>();

  var _count = 0;

  Stream<int> get stream => _controller.stream;

  void increment() {
    ++_count;
    _controller.sink.add(_count);
  }

  void dispose() {
    _controller.close();
  }
}
