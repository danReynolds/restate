import 'dart:async';
import 'package:state_blocs/state_change_tuple.dart';

/// A state class that holds a current value that can be accessed synchronously
/// using [value] or as a stream using [stream].
class StateBloc<T> {
  final _inputController = StreamController<T?>();
  final _outputController = StreamController<StateChangeTuple<T?>>.broadcast();

  T? _value;
  T? _prevValue;
  bool _hasEvent = false;

  StateBloc([T? initialValue]) {
    _inputController.stream.listen((newValue) {
      if (!_hasEvent) {
        _hasEvent = true;
      }
      _prevValue = _value;
      _value = newValue;

      _outputController.add(StateChangeTuple(_prevValue, _value));
    });

    if (initialValue != null) {
      /// We assign [initialValue] outside of [add] first so that it is synchronously
      /// accessible.
      _value = initialValue;
      add(initialValue);
    }
  }

  /// Closes the internal stream controller.
  dispose() {
    _inputController.close();
    _outputController.close();
  }

  /// Returns a stream that emits all of changes to the value of the [StateBloc]
  /// as a [StateChangeTuple] containing the current and previous value. When the
  /// [StateBloc] receives its first value, the changes stream will emit immediately
  /// with a previous value of [initialValue] or null if no initialValue was provided.
  Stream<StateChangeTuple<T?>> get changes {
    StreamController<StateChangeTuple<T?>>? _downStreamController;
    _downStreamController =
        StreamController<StateChangeTuple<T?>>.broadcast(onListen: () {
      if (_hasEvent) {
        _downStreamController!.add(StateChangeTuple(_prevValue, _value));
      }
      _outputController.stream.listen((data) {
        _downStreamController!.add(data);
      });
    });

    return _downStreamController.stream;
  }

  /// Returns a stream that emits all of the updates to the [StateBloc], starting
  /// with the current value.
  Stream<T?> get stream {
    return changes.map((stateChange) => stateChange.current);
  }

  /// The current value of the [StateBloc].
  T? get value {
    return _value;
  }

  /// A Future that waits for a value to be emitted to the [StateBloc]. Completes
  /// with the current value if the [StateBloc] has already had a value emitted.
  Future<T?> get current {
    return stream.first;
  }

  /// Updates the current value of the [StateBloc] to the provided value.
  void add(T? value) {
    _inputController.add(value);
  }

  /// Sets the current value of the [StateBloc] to the returned value of the [updateFn].
  /// The [updateFn] is provided the current value of the [StateBloc].
  T? setValue(T? Function(T? currentValue) updateFn) {
    final updatedValue = updateFn(_value);
    add(updatedValue);
    return updatedValue;
  }
}
