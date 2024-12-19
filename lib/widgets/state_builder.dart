import 'package:flutter/widgets.dart';

import '../core/state_manager.dart';

typedef StateWidgetBuilder<T> = Widget Function(BuildContext context, T value);

/// Widget to rebuild UI based on state changes
class StateBuilder<T> extends StatefulWidget {
  final StateManager<T> state;
  final StateWidgetBuilder<T> builder;

  const StateBuilder({
    Key? key,
    required this.state,
    required this.builder,
  }) : super(key: key);

  @override
  _StateBuilderState<T> createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T> extends State<StateBuilder<T>> {
  late T _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.state.value;
    widget.state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    setState(() {
      _currentValue = widget.state.value;
    });
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}