import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/services/stream/base/base_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/subjects.dart';

class MessagingService extends IService<Map<String, dynamic>?> {
  MessagingService() : super(BehaviorSubject.seeded(null)) {
    FirebaseMessaging.onMessage.listen(_onMessageReceived);
  }

  final _logger = GetIt.instance.get<Logger>();

  void _onMessageReceived(RemoteMessage message) {
    _logger.d('Received new message:\n${message.data}');
    behaviorSubject.add(message.data);
  }
}
