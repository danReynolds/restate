/// A tuple containing the current and previous value of the state change.
class StateChangeTuple<T> {
  /// The value of the previous state.
  final T? previous;

  /// The value of the current state.
  final T? current;

  StateChangeTuple(this.previous, this.current);
}
