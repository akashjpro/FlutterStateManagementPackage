import '../core/state_manager.dart';

extension AsyncStateManager<T> on StateManager<T> {
  /// Update the state asynchronously
  Future<void> updateAsync(Future<T> Function(T currentValue) asyncUpdater) async {
    value = await asyncUpdater(value);
  }
}
