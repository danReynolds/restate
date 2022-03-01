# Restate

**Restate** is a reactive state management library for Flutter applications with no dependencies and < 200 lines.

Each Restate [StateBloc](https://pub.dev/documentation/restate/latest/state_bloc/StateBloc-class.html) holds a single state value accessible synchronously, as a [Future](https://dart.dev/codelabs/async-await#what-is-a-future) or as a [Stream](https://dart.dev/tutorials/language/streams) of values.

* [StateBloc.value](https://pub.dev/documentation/restate/latest/state_bloc/StateBloc/value.html) - Returns the current state value synchronously.
* [StateBloc.current](https://pub.dev/documentation/restate/latest/state_bloc/StateBloc/current.html) - Returns a Future that resolves with the current value if it already has a value or otherwise waits for one to be added.
* [StateBloc.stream](https://pub.dev/documentation/restate/latest/state_bloc/StateBloc/stream.html) - Returns a Stream of updates to the state value.
* [StateBloc.changes](https://pub.dev/documentation/restate/latest/state_bloc/StateBloc/changes.html) - Returns a Stream of changes to the state value including the current and previous value.

## Reading the current value

```dart
import 'package:restate/restate.dart';

final counterState = StateBloc<int>(0);
print(counterState.value); // 0
counterState.add(1);
print(counterState.value); // 1
```

## Listening to a Stream of values

```dart
import 'package:restate/restate.dart';

final counterState = StateBloc<int>(0);

counterState.stream.listen((value) {
  print(value);
  // 0
  // 1
  // 2
});

counterState.add(1);
counterState.add(2);
```

## Listening to a Stream of changes

```dart
import 'package:restate/restate.dart';

final counterState = StateBloc<int>(0);

counterState.changes.listen((value) {
  print('${value.previous}->${value.current}');
  // null->0
  // 0->1
  // 1->2
});

counterState.add(1);
counterState.add(2);
```

## Waiting for the current value

```dart
import 'package:restate/restate.dart';

final counterState = StateBloc<int>();

counterState.current.then((value) => print(value)); // 1
counterState.add(1);
counterState.current.then((value) => print(value)); // 1
```

## Accessing State in Widgets

Accesing and listening for updates to your state is as simple as creating a [StateBloc](https://pub.dev/documentation/restate/latest/state_bloc/StateBloc-class.html)
and then using a [StreamBuilder](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html) to rebuild your widget when data changes:

```dart
final counterStateBloc = StateBloc<int>(0);

class MyWidget extends StatelessWidget {
  @override
  build(context) {
    return StreamBuilder(
      stream: counterStateBloc.stream,
      builder: (context, counterSnap) {
        if (!counterSnap.hasData) {
          return Text('Waiting for value...');
        }

        final counter = counterSnap.data;

        return Column(
          children: [
            Text('Counter: $counter'),
            ElevatedButton(
              onPressed: () {
                counterStateBloc.add(counter + 1);
              },
            ),
          ],
        );
      }
    )
  }
}
```

That's it! You can run the [demo](https://github.com/danReynolds/restate/tree/master/example) to see a more in-depth working example.

## Updating a StateBloc value

Generally, the [StateBloc.add](https://pub.dev/documentation/restate/latest/state_bloc/StateBloc/add.html) API is sufficient for updating the current value held by a `StateBloc`. Sometimes, however, you may be working with complex objects that need to be mutated.

To keep your state values immutable, you can see if it's possible to use a `copyWith` function to return new objects:

```dart
class User {
  String firstName;
  String lastName;

  User({
    required this.firstName,
    required this.lastName,
  });

  User copyWith({
    String? firstName,
    String? lastName,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}

final user = User(firstName: 'Anakin', lastName: 'Skywalker');
final userState = UserStateBloc<User>(user);

userState.add(
  userState.value.copyWith(
    firstName: 'Darth',
    lastName: 'Vader',
  ),
);
```

Many Flutter data objects like [TextStyle](https://api.flutter.dev/flutter/painting/TextStyle-class.html) already support this pattern.

If you instead need to mutate the current value, you can use the [StateBloc.setValue](https://pub.dev/documentation/restate/latest/state_bloc/StateBloc/setValue.html) API:

```dart
final user = User(firstName: 'Anakin', lastName: 'Skywalker');
final userState = UserStateBloc<User>(user);

userState.setValue((currentUser) {
  currentUser.firstName = 'Darth';
  currentUser.lastName = 'Vader';
});
```

The `setValue` API provides the current value held by the `StateBloc`, allowing you to mutate it as necessary, and then re-emits that object on the [StateBloc.stream](https://pub.dev/documentation/restate/latest/state_bloc/StateBloc/stream.html).

## Feedback Welcome

Let us know if there's a feature or changes you would like to see to **Restate** on [GitHub](https://github.com/danReynolds/restate) and happy coding!
