import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:state_management/state_management.dart';

final counterState = StateManager<int>(initialValue: 0);

void main() {
  runApp(
    StateProvider(
      states: [counterState],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom State Manager')),
      body: Center(
        child: StateBuilder<int>(
          state: counterState,
          builder: (context, value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Counter: $value',
                  style: TextStyle(fontSize: 45),
                ),
                SizedBox(height: 40),
                OutlinedButton(
                    onPressed: () {
                      fetchAndUpdate();
                    },
                    child: const Text(
                      "Count await",
                      style: TextStyle(fontSize: 45),
                    )),
                SizedBox(height: 40),
                OutlinedButton(
                    onPressed: () {
                      counterState.reset();
                    },
                    child: const Text(
                      "Reset",
                      style: TextStyle(fontSize: 45),
                    ))
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counterState.update((value) => value + 1);
          fetchAndUpdate();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> fetchAndUpdate() async {
    await counterState.updateAsync((value) async {
      await Future.delayed(Duration(seconds: 1));
      return value + 10; // Giả lập fetch dữ liệu
    });
  }
}
