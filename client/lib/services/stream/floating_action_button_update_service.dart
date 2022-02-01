import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';

class FloatingActionButtonUpdateService {
  final BehaviorSubject<bool> _behaviorSubject = BehaviorSubject.seeded(false);
  ValueStream<bool> get stream$ => _behaviorSubject.stream;

  bool get currentHasValue => _behaviorSubject.hasValue;
  bool get current => _behaviorSubject.value;

  void onClickFloatingActionButtonOrScrollUpFarEnough() async {
    _behaviorSubject.add(false);
  }

  void onScrollDownFarEnough() async {
    _behaviorSubject.add(true);
  }
}
