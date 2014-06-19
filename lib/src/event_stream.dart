part of relay;

/// An [EventStream] is wrapper around a standard Dart [Stream], but provides utility
/// methods for creating other streams or properties.
class EventStream<T> extends StreamView<T> implements Observable<T> {
  EventStream(Stream<T> stream) : super(stream);

  /// Returns a new stream that contains events from this stream and the [other] stream.
  EventStream merge(Stream other) => new EventStream(new _MergedStream([this, other]));

  /// Returns a [Property] where the first value is the [initalValue] and values after
  /// that are the result of [combine].
  ///
  /// [combine] is an accumulator function where its first argument is either the initial
  /// value or the result of the last combine, and the second argument is the next value
  /// in this stream.
  Property<T> scan(T initialValue, T combine(T value, T element)) {
    return new EventStream<T>(new _ScanStream(this, initialValue, combine))
        .asPropertyWithInitialValue(initialValue);
  }

  /// Returns a new stream that will begin forwarding events from this stream when the
  /// [future] completes.
  EventStream<T> skipUntil(Future future) {
    return new EventStream<T>(new _SkipUntilStream(this, future));
  }

  /// Returns a new stream that contains events from this stream until the [future]
  /// completes.
  EventStream<T> takeUntil(Future future) {
    return new EventStream<T>(new _TakeUntilStream(this, future));
  }

  /// Returns a new stream that upon forwarding an event from this stream, will ignore
  /// any subsequent events until [duration], after which the last event will be
  /// forwarded.
  ///
  /// The returned stream will not throttle errors.
  EventStream<T> throttle(Duration duration) {
    return new EventStream<T>(new _ThrottleStream(this, duration));
  }

  /// Returns a [Property] where the first value will be the next value from this stream.
  Property<T> asProperty() {
    return new _StreamProperty(this);
  }

  /// Returns a [Property] where the first value will be the [initialValue], and values
  /// after that will be the values from this stream.
  Property<T> asPropertyWithInitialValue(T initialValue) {
    return new _StreamProperty.initialValue(this, initialValue);
  }
}