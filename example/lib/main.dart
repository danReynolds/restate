import 'package:flutter/material.dart';
import 'package:state_blocs/state_blocs.dart';
import 'package:state_blocs/state_change_tuple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

StateBloc<int> _counterBloc = StateBloc<int>();

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _counterBloc.setValue((val) => (val ?? 0) + 1);
              },
              child: const Text('Increment count'),
            ),
            const SizedBox(height: 16),
            StreamBuilder<int?>(
              stream: _counterBloc.stream,
              builder: (context, counterBlocSnap) {
                if (!counterBlocSnap.hasData) {
                  return const SizedBox();
                }

                final clickedCount = counterBlocSnap.data!;

                return Text('Clicked $clickedCount times');
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: FutureBuilder<int?>(
                future: _counterBloc.current,
                builder: (context, counterBlocSnap) {
                  if (!counterBlocSnap.hasData) {
                    return const Text('The counter has not been clicked.');
                  }

                  final clickedCount = counterBlocSnap.data;

                  if (clickedCount == 0) {
                    return const Text('The counter has not been clicked.');
                  }

                  return const Text('The counter has been clicked!');
                },
              ),
            ),
            StreamBuilder<StateChangeTuple?>(
              stream: _counterBloc.changes,
              builder: (context, counterChangeBlocSnap) {
                if (!counterChangeBlocSnap.hasData) {
                  return const SizedBox();
                }

                final clickCountChange = counterChangeBlocSnap.data!;

                return Text(
                  'Changed from ${clickCountChange.previous ?? 0} to ${clickCountChange.current}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
