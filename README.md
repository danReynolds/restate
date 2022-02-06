# State Blocs

**StateBlocs** is a lightweight state management libray for Flutter applications with no dependencies and < 200 lines.

Each [StateBloc]() holds a single state value accessible synchronously using [StateBloc.value](), as a [Future](https://dart.dev/codelabs/async-await#what-is-a-future) using [StateBloc.current]() or as a [Stream](https://dart.dev/tutorials/language/streams) using [StateBloc.stream]() and [StateBloc.changes]() for a stream of the current and previous value.

## Reading the current value

```dart
import 'package:state_blocs/state_blocs.dart';

final counterState = StateBloc<int>(0);
print(counterState.value); // 0
counterState.add(1);
print(counterState.value); // 1
```

## Listening to a Stream of values

```dart
import 'package:state_blocs/state_blocs.dart';

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
import 'package:state_blocs/state_blocs.dart';

final counterState = StateBloc<int>(0);

counterState.stream.listen((value) {
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
import 'package:state_blocs/state_blocs.dart';

final counterState = StateBloc<int>();

counterState.current.then((value) => print(value)); // 1
counterState.add(1);
```

## Building widgets with StateBlocs

Using `StateBlocs` to manage the state of your Flutter application and get live updates is easy as creating a [StateBloc]()
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

That's it! You can run the [demo]() to see a more in-depth working example.

## Updating a StateBloc value

Generally, the [StateBloc.add]() API is sufficient for updating the current value held by a [StateBloc]. Sometimes, however,
you may be working with complex objects that need to be mutated.

To keep your state values immutable, you can see if it's possible to use a `copyWith` function to your object so that each value emitted by the `StateBloc` is unique:

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
final userState = UserStateBloc<User>();

userState.add(
  userState.value.copyWith(
    firstName: 'Darth',
    lastName: 'Vader',
  ),
);
```

Many Flutter data objects like [TextStyle](https://api.flutter.dev/flutter/painting/TextStyle-class.html) already support this pattern.

If you instead are looking to mutate the current value, you can use the [StateBloc.setValue]() API:

```dart
final user = User(firstName: 'Anakin', lastName: 'Skywalker');
final userState = UserStateBloc<User>();

userState.setValue((currentUser) {
  currentUser.firstName = 'Darth';
  currentUser.lastName = 'Vader';
});
```

The `setValue` API provides the current value held by the `StateBloc`, allowing you to mutate it as necessary, and then will re-emit that object on the [StateBloc.stream].

## Give Feedback

Let us know if there's a feature or change you would like to see to State Blocs.