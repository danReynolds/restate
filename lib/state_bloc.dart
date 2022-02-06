import 'dart:async';
import 'package:restate/state_change_tuple.dart';
import 'package:restate/stream/extensions/start_with.dart';

/// A [Stream] of values emitted by the [StateBloc] beginning with its current value.
class StateBlocStream<T> extends Stream<T?> {
  final Stream<StateChangeTuple<T?>> Function() factory;

  StateBlocStream._({
    required this.factory,
  });

  @override
  StreamSubscription<T?> listen(
    void Function(T? value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return factory().map((val) => val.current).listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }
}

/// A [Stream] of [StateBloc] value changes beginnign with its current and previous
/// value.
class StateBlocChangeStream<T> extends Stream<StateChangeTuple<T?>> {
  final Stream<StateChangeTuple<T?>> Function() factory;

  StateBlocChangeStream._({
    required this.factory,
  });

  @override
  StreamSubscription<StateChangeTuple<T?>> listen(
    void Function(StateChangeTuple<T?> value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return factory().listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

/// A class that holds a single state value accessible synchronously
/// using [StateBloc.value], as a [Future] using [StateBloc.current] or as a
/// stream using [StateBloc.stream] and [StateBloc.changes] for a stream of the
/// current and previous value.
class StateBloc<T> {
  final _controller = StreamController<StateChangeTuple<T?>>.broadcast();
  late StateBlocStream<T> _stateStream;
  late StateBlocChangeStream<T> _stateChangeStream;

  T? _value;
  T? _prevValue;
  bool _hasEmitted = false;

  StateBloc([T? initialValue]) {
    _stateStream = StateBlocStream<T>._(
      factory: _streamFactory,
    );
    _stateChangeStream = StateBlocChangeStream<T>._(
      factory: _streamFactory,
    );

    if (initialValue != null) {
      add(initialValue);
    }
  }

  Stream<StateChangeTuple<T?>> _streamFactory() {
    if (_hasEmitted) {
      return _controller.stream
          .startWith(StateChangeTuple<T?>(_prevValue, _value));
    }
    return _controller.stream;
  }

  _updateValue(T? value) {
    _prevValue = _value;
    _value = value;
  }

  /// Disposes all resources held by the [StateBloc].
  dispose() {
    close();
  }

  /// Closes the [StreamController] for the [StateBloc]. No further items will be emitted
  /// by the [StateBloc] Stream or Future interfaces.
  close() {
    _controller.close();
  }

  /// Returns whether the [StateBloc]'s stream controller is able to receive new events
  /// or has been closed.
  bool get isClosed {
    return _controller.isClosed;
  }

  /// Returns a stream that emits all of changes to the value of the [StateBloc] as a
  /// [StateChangeTuple] containing the [StateChangeTuple.current] and [StateChangeTuple.previous] value.
  /// If the [StateBloc] is instantiated with an [initialValue], the [StateBloc.changes] stream will first emit
  /// a tuple of [StateChangeTuple.current] equal to the initialValue and a [StateChangeTuple.previous] of null.
  Stream<StateChangeTuple<T?>> get changes {
    return _stateChangeStream;
  }

  /// Returns a stream that emits all of the updates to the value held by the [StateBloc],
  /// starting with the current value.
  Stream<T?> get stream {
    return _stateStream;
  }

  /// The current value of the [StateBloc].
  T? get value {
    return _value;
  }

  /// Updates the value of the [StateBloc].
  set value(T? value) {
    add(value);
  }

  /// A [Future] that waits for a value to be added to the [StateBloc]. Completes
  /// with the current value if the [StateBloc] already has a value.
  Future<T?> get current {
    return stream.first;
  }

  /// A Future that waits for the next value to be added to the [StateBloc].
  Future<T?> get next {
    return _controller.stream.first.then((data) => data.current);
  }

  /// Updates the current value of the [StateBloc] to the provided value.
  void add(T? value) {
    _updateValue(value);
    if (!_hasEmitted) {
      _hasEmitted = true;
    }
    _controller.add(StateChangeTuple(_prevValue, _value));
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
}
