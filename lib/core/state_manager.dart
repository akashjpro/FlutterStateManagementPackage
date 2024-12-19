
import 'dart:ui';

/// Core class to manage state
class StateManager<T> {
  T _value;
  final List<VoidCallback> _listeners = [];

  StateManager({required T initialValue}) : _value = initialValue;

  /// Get current value
  T get value => _value;

  /// Update state synchronously
  void update(T Function(T currentValue) updater) {
    _value = updater(_value);
    _notifyListeners();
  }

  /// Set new value directly
  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      _notifyListeners();
    }
  }

  /// Reset state to default
  void reset() {
    if (_value is num) {
      _value = 0 as T;
    } else if (_value is String) {
      _value = '' as T;
    } else if (_value is List || _value is Map) {
      _value = [] as T;
    }
    _notifyListeners();
  }

  /// Add listener to watch for state changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify listeners of changes
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}