import 'dart:async';

// StreamTransformer implementation based on Dart docs:
// https://api.flutter.dev/flutter/dart-async/StreamTransformer/StreamTransformer.html.
// Used for transforming an existing input stream to manipulate the data it emits on initially
// listening to the stream and subseqent data events.
StreamTransformer<T, T> createTransformer<T>({
  void Function(StreamController<T> controller)? onListen,
  void Function(StreamController<T> controller)? onData,
}) {
  return StreamTransformer<T, T>(
    (Stream input, bool cancelOnError) {
      // A synchronous stream controller is intended for cases where
      // an already asynchronous event triggers an event on a stream.
      /// Instead of adding the event to the stream in a later microtask,
      /// causing extra latency, the event is instead fired immediately by the
      /// synchronous stream controller, as if the stream event was
      /// the current event or microtask.
      final controller = StreamController<T>(sync: true);

      controller.onListen = () {
        onListen?.call(controller);
        var subscription = input.listen(
          (data) {
            if (onData != null) {
              onData(data);
            } else {
              controller.add(data);
            }
          },
          onError: controller.addError,
          onDone: controller.close,
          cancelOnError: cancelOnError,
        );
        // Controller forwards pause, resume and cancel events.
        controller
          ..onPause = subscription.pause
          ..onResume = subscription.resume
          ..onCancel = subscription.cancel;
      };
      // Return a new [StreamSubscription] by listening to the controller's
      // stream.
      return controller.stream.listen(null);
    },
  );
}
