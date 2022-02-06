import 'package:flutter_test/flutter_test.dart';
import 'package:restate/restate.dart';
import 'package:restate/state_change_tuple.dart';

class TestModel {
  bool test;

  TestModel(this.test);

  TestModel copyWith({
    required bool value,
  }) {
    return TestModel(value);
  }
}

class TestModelMatcher extends Matcher {
  TestModel expected;
  late TestModel actual;
  TestModelMatcher(this.expected);

  @override
  Description describe(Description description) {
    return description.add(
      "has expected value: ${expected.test}",
    );
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    return mismatchDescription.add(
      "has expected value: ${matchState['actual'].test}",
    );
  }

  @override
  bool matches(actual, Map matchState) {
    final _actual = actual as TestModel;
    this.actual = _actual;
    return actual.test == expected.test;
  }
}

class StateChangeTupleMatcher extends Matcher {
  StateChangeTuple expected;
  late StateChangeTuple actual;
  StateChangeTupleMatcher(this.expected);

  @override
  Description describe(Description description) {
    return description.add(
      "has expected values current: ${expected.current}, previous: ${expected.previous}",
    );
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    return mismatchDescription.add(
      "has expected values current: ${matchState['actual'].current}, previous: ${matchState['actual'].previous}",
    );
  }

  @override
  bool matches(actual, Map matchState) {
    final _actual = actual as StateChangeTuple;
    this.actual = _actual;
    return actual.current == expected.current &&
        actual.previous == expected.previous;
  }
}

void main() {
  group('constructor', () {
    late StateBloc<int> stateBloc;

    tearDown(() {
      stateBloc.dispose();
    });

    test('defaults to null if not provided an initial value', () {
      stateBloc = StateBloc();
      expect(stateBloc.value, null);
    });

    test('defaults to the initialValue when provided', () {
      stateBloc = StateBloc(0);
      expect(stateBloc.value, 0);
    });
  });

  group('value', () {
    late StateBloc<int> stateBloc;

    setUp(() {
      stateBloc = StateBloc();
    });

    tearDown(() {
      stateBloc.dispose();
    });

    test('returns the current value of the StateBloc', () {
      expect(stateBloc.value, null);
      stateBloc.add(1);
      expect(stateBloc.value, 1);
    });
  });

  group('current', () {
    late StateBloc<int> stateBloc;

    setUp(() {
      stateBloc = StateBloc();
    });

    tearDown(() {
      stateBloc.dispose();
    });

    test(
      'returns a future that resolves immediately if a value has already been added to the StateBloc',
      () {
        stateBloc.add(1);
        expect(stateBloc.current, completion(1));
      },
    );

    test(
      'returns a future that resolves immediately if the stateBloc was provided an initialValue',
      () {
        stateBloc = StateBloc(0);
        expect(stateBloc.current, completion(0));
      },
    );

    test(
      'returns a future that resolves once a value has been added to the StateBloc',
      () {
        expect(stateBloc.current, completion(1));
        stateBloc.add(1);
      },
    );
  });

  group('next', () {
    late StateBloc<int> stateBloc;

    setUp(() {
      stateBloc = StateBloc();
    });

    tearDown(() {
      stateBloc.dispose();
    });

    test(
      'returns a future that resolves when the next value is added to the stream',
      () {
        stateBloc.add(0);
        expect(stateBloc.next, completion(1));
        stateBloc.add(1);
      },
    );
  });

  group('stream', () {
    late StateBloc<int> stateBloc;

    setUp(() {
      stateBloc = StateBloc();
    });

    tearDown(() {
      stateBloc.dispose();
    });

    test('emits all of the provided values', () {
      expectLater(stateBloc.stream, emitsInOrder([1, 2, 3]));
      stateBloc.add(1);
      stateBloc.add(2);
      stateBloc.add(3);
    });
  });

  group('changes', () {
    late StateBloc<int> stateBloc;

    setUp(() {
      stateBloc = StateBloc();
    });

    tearDown(() {
      stateBloc.dispose();
    });

    test('emits all of the provided state change tuples', () {
      expectLater(
        stateBloc.changes,
        emitsInOrder([
          StateChangeTupleMatcher(StateChangeTuple(null, 1)),
          StateChangeTupleMatcher(StateChangeTuple(1, 2)),
          StateChangeTupleMatcher(StateChangeTuple(2, 3)),
        ]),
      );
      stateBloc.add(1);
      stateBloc.add(2);
      stateBloc.add(3);
    });

    test(
        'emits all of the provided state change tuples beginning with the initial value',
        () {
      stateBloc = StateBloc(0);

      expectLater(
        stateBloc.changes,
        emitsInOrder([
          StateChangeTupleMatcher(StateChangeTuple(null, 0)),
          StateChangeTupleMatcher(StateChangeTuple(0, 1)),
          StateChangeTupleMatcher(StateChangeTuple(1, 2)),
          StateChangeTupleMatcher(StateChangeTuple(2, 3)),
        ]),
      );
      stateBloc.add(1);
      stateBloc.add(2);
      stateBloc.add(3);
    });
  });

  group('add', () {
    late StateBloc<int> stateBloc;

    setUp(() {
      stateBloc = StateBloc();
    });

    tearDown(() {
      stateBloc.dispose();
    });

    test('updates the StateBloc to the provided value', () {
      stateBloc.add(1);
      expect(stateBloc.value, 1);
    });
  });

  group('setValue', () {
    late StateBloc<TestModel> stateBloc;

    setUp(() {
      stateBloc = StateBloc(TestModel(false));
    });

    tearDown(() {
      stateBloc.dispose();
    });

    test('updates the StateBloc to the returned value', () {
      stateBloc.setValue((currentVal) {
        currentVal?.test = true;
      });
      expect(stateBloc.value!.test, true);
      expectLater(stateBloc.stream, emits(TestModelMatcher(TestModel(true))));
    });
  });
}
