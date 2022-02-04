import 'dart:async';
import 'package:state_blocs/state_change_tuple.dart';

class StateBlocStream<T> extends Stream<StateChangeTuple<T?>> {
  final _inputController = StreamController<StateChangeTuple<T?>>();
  final _outputController = StreamController<StateChangeTuple<T?>>.broadcast();
  bool _hasEvent = false;
  T? _value;
  T? _prevValue;

  StateBlocStream([T? initialValue]) {
    _inputController.stream.listen((newValue) {
      if (!_hasEvent) {
        _hasEvent = true;
      }
      _outputController.add(newValue);
    });

    // If the StateBloc is instantiated with an initialValue then it has a value to emit
    // to subscribers.
    _hasEvent = initialValue != null;

    if (initialValue != null) {
      add(initialValue);
    }
  }

  @override
  StreamSubscription<StateChangeTuple<T?>> listen(
    void Function(StateChangeTuple<T?> value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _changes.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  Stream<StateChangeTuple<T?>> get stream {
    return this;
  }

  /// Returns a stream that emits all of changes to the value of the [StateBloc]
  /// as a [StateChangeTuple] containing the current and previous value. When the
  /// [StateBloc] receives its first value, the changes stream will emit immediately
  /// with a previous value of [initialValue] or null if no [initialValue] was provided.
  Stream<StateChangeTuple<T?>> get _changes {
    StreamController<StateChangeTuple<T?>>? _downStreamController;
    _downStreamController = StreamController<StateChangeTuple<T?>>(
      onListen: () {
        if (_hasEvent) {
          _downStreamController!.add(StateChangeTuple(_prevValue, _value));
        }
        _outputController.stream.listen((data) {
          _downStreamController!.add(data);
        }, onDone: () {
          _downStreamController!.close();
        });
      },
    );

    return _downStreamController.stream;
  }

  _updateValue(T? value) {
    _prevValue = _value;
    _value = value;
  }

  /// Closes the internal stream controller.
  close() {
    _inputController.close();
    _outputController.close();
  }

  void add(T? value) {
    _updateValue(value);
    _inputController.add(StateChangeTuple(_prevValue, _value));
  }

  /// Executes the provided [updateFn] and then re-emits the updated value on the stream.
  /// Consider the following example where the current value is updated:
  /// ```dart
  /// final userBloc = StateBloc(UserModel(name: 'Luke'));
  /// userBloc.setValue((user) => user.name = "Luke Skywalker");
  /// ```
  /// setValue will re-emit the user object on the stream, allowing all listeners
  /// to receive the updated value.
  void setValue(T? Function(T? currentValue) updateFn) {
    updateFn(_value);
    add(_value);
  }

  /// Returns whether the [StateBloc]'s stream controller is able to receive new events
  /// or has been closed.
  bool get isClosed {
    return _inputController.isClosed;
  }

  /// The current value of the [StateBloc].
  T? get value {
    return _value;
  }
}

/// A state class that holds a current value accessible synchronously
/// using [StateBloc.value], as a [Future] using [StateBloc.current] or as a stream using [StateBloc.stream].
class StateBloc<T> {
  late StateBlocStream<T?> _stream;

  StateBloc([T? initialValue]) {
    _stream = StateBlocStream(initialValue);
  }

  Stream<T?> get stream {
    return _stream.map((data) => data.current);
  }

  StateBlocStream<T?> get changes {
    return _stream;
  }

  /// Disposes all resources held by the [StateBloc].
  dispose() {
    close();
  }

  close() {
    _stream.close();
  }

  /// Returns whether the [StateBloc]'s stream controller is able to receive new events
  /// or has been closed.
  bool get isClosed {
    return _stream.isClosed;
  }

  /// The current value of the [StateBloc].
  T? get value {
    return _stream.value;
  }

  /// A Future that waits for a value to be emitted to the [StateBloc]. Completes
  /// with the current value if the [StateBloc] already has a value.
  Future<T?> get current {
    return stream.first;
  }

  /// A Future that waits for the next value emitted to the [StateBloc].
  // Future<T?> get next {
  //   return _outputController.stream.first.then((data) => data.current);
  // }

  /// Updates the current value of the [StateBloc] to the provided value.
  void add(T? value) {
    _stream._updateValue(value);
  }

  /// Executes the provided [updateFn] and then re-emits the updated value on the stream.
  /// Consider the following example where the current value is updated:
  /// ```dart
  /// final userBloc = StateBloc(UserModel(name: 'Luke'));
  /// userBloc.setValue((user) => user.name = "Luke Skywalker");
  /// ```
  /// setValue will re-emit the user object on the stream, allowing all listeners
  /// to receive the updated value.
  void setValue(T? Function(T? currentValue) updateFn) {
    _stream.setValue(updateFn);
  }
}
