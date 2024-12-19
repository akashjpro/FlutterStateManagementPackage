import 'package:flutter/widgets.dart';

import '../core/state_manager.dart';

/// Provides states to the widget tree
class StateProvider extends InheritedWidget {
  final List<StateManager> states;

  const StateProvider({
    Key? key,
    required this.states,
    required Widget child,
  }) : super(key: key, child: child);

  /// Retrieve state from context
  static T of<T>(BuildContext context) {
    final StateProvider? provider =
    context.dependOnInheritedWidgetOfExactType<StateProvider>();
    return provider!.states.firstWhere((s) => s is StateManager<T>) as T;
  }

  @override
  bool updateShouldNotify(covariant StateProvider oldWidget) {
    return oldWidget.states != states;
  }
}
