import 'dart:async';

import 'package:restate/stream/transformer.dart';

StreamTransformer<T?, T> whereTypeStreamTransformer<T>() {
  return createTransformer<T?, T>(
    onData: (controller, data) {
      if (data is T) {
        controller.add(data);
      }
    },
  );
}

extension WhereType on Stream {
  Stream<T> whereType<T>() {
    return transform(whereTypeStreamTransformer<T>());
  }
}
