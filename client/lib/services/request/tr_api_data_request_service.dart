import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/tr/tr_request_model.dart';
import 'package:solidtrade/data/common/shared/tr/tr_request_response.dart';
import 'package:solidtrade/services/util/debug/log.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TrApiDataRequestService {
  final Map<int, String> _requestMessageStrings = {};
  final List<TrRequestModel> _runningRequests = [];

  final String _initialTrConnectString = ConfigReader.getTrConnectString();
  final Uri _endpointUri = Uri.parse(ConfigReader.getTrEndpoint());
  late WebSocketChannel _socketChannel;

  DateTime _lastEchoSent = DateTime.now();
  bool _initialConnect = true;
  int _currentId = 0;

  TrApiDataRequestService() {
    _initializeConnection();
  }

  void _initializeConnection() {
    void reconnect() {
      Log.w("Lost connection to api");
      Log.d("Trying to reconnect");
      _initializeConnection();
    }

    _socketChannel = WebSocketChannel.connect(_endpointUri);

    _socketChannel.stream.listen(
      (messageAsDynamic) => _onMessageReceived(messageAsDynamic),
      onDone: () => reconnect(),
      onError: (_) => reconnect(),
    );

    _sendMessage(_initialTrConnectString);
  }

  void _onMessageReceived(String message) {
    Log.d(message);

    if (!_initialConnect && message == "connected") {
      var requestMessageStrings = Map<int, String>.from(_requestMessageStrings);

      for (var item in requestMessageStrings.entries) {
        if (_runningRequests.any((r) => r.id == item.key)) {
          _sendMessage("sub ${item.key} ${item.value}");
        } else {
          _requestMessageStrings.remove(item);
        }
      }

      _initialConnect = false;
    }

    if (message == "connected" || message.startsWith("echo")) {
      _initialConnect = false;
      return;
    }

    if (DateTime.now().difference(_lastEchoSent).inSeconds > 30) {
      _lastEchoSent = DateTime.now();
      _sendMessage("echo ${_lastEchoSent.millisecondsSinceEpoch}");
    }

    var id = _parseMessageId(message);

    if (id == -1) return;

    var messageResponse = _getMessageResponse(message);

    if (messageResponse == null) return;

    if (!_runningRequests.any((r) => r.id == id)) {
      unsub(id);
      return;
    }

    var request = _runningRequests.firstWhere((r) => r.id == id);
    request.onResponseCallback.call(messageResponse);
  }

  int _parseMessageId(String message) {
    String s = message.substring(0, message.indexOf(" "));

    return int.tryParse(s) ?? -1;
  }

  String? _getMessageResponse(String message) {
    int index = message.indexOf('{');

    return index < 0 ? null : message.substring(index);
  }

  void _sendMessage(String message) {
    Log.d("Send websocket message: " + message);
    _socketChannel.sink.add(message);
  }

  int _generateNewId() => ++_currentId;

  Future<RequestResponse<T>> makeRequest<T>(String requestString) async {
    Completer<RequestResponse<T>> completer = Completer();

    var id = _generateNewId();

    var model = TrRequestModel(
        id: id,
        onResponseCallback: (response) {
          unsub(id);
          if (response.startsWith("{\"errors\"")) {
            completer.complete(RequestResponse<T>.failedWithUserfriendlyMessage("Something went wrong. Please try again later."));
            return;
          }

          completer.complete(RequestResponse.successful(JsonMapper.deserialize<T>(response)!));
        });

    _sendMessage("sub $id $requestString");
    _requestMessageStrings[id] = requestString;
    _runningRequests.add(model);

    try {
      return await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      return Future.value(RequestResponse.failedWithUserfriendlyMessage("Loading data took too long. Please try again later."));
    }
  }

  BehaviorSubject<TrRequestResponse<T>?> makeRequestAsync<T>(String requestString) {
    BehaviorSubject<TrRequestResponse<T>?> subject = BehaviorSubject.seeded(null);
    var id = _generateNewId();

    var model = TrRequestModel(
        id: id,
        onResponseCallback: (response) {
          if (response.startsWith("{\"errors\"")) {
            var errorResult = RequestResponse<T>.failedWithUserfriendlyMessage("Something went wrong. Please try again later.");
            subject.add(TrRequestResponse(id, errorResult));
            return;
          }

          var successResult = RequestResponse<T>.successful(JsonMapper.deserialize<T>(response)!);
          subject.add(TrRequestResponse(id, successResult));
        });

    _sendMessage("sub $id $requestString");
    _requestMessageStrings[id] = requestString;
    _runningRequests.add(model);

    return subject;
  }

  void unsub(int id) {
    _sendMessage("unsub $id");
    _runningRequests.removeWhere((r) => r.id == id);
    _requestMessageStrings.removeWhere((messageId, _) => messageId == id);
  }
}
