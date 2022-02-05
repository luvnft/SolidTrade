import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';

abstract class BaseService<T> {
  final BehaviorSubject<T> behaviorSubject;

  BaseService(this.behaviorSubject);

  ValueStream<T> get stream$ => behaviorSubject.stream;

  bool get currentHasValue => behaviorSubject.hasValue;
  T get current => behaviorSubject.value;
}
