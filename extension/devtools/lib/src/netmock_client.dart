import 'dart:developer' as developer;

class NetmockClient {
  static NetmockClient? _instance;
  static NetmockClient get instance => _instance ??= NetmockClient._();

  NetmockClient._();

  bool _isMockingEnabled = false;
  bool _isRecording = true;
  final Map<String, Map<String, dynamic>> _mocks = {};
  final Map<String, Map<String, dynamic>> _requests = {};

  bool get isMockingEnabled => _isMockingEnabled;
  bool get isRecording => _isRecording;

  void initialize() {
    _registerServiceExtensions();
  }

  void _registerServiceExtensions() {
    // Register service extensions for DevTools communication
    developer.registerExtension('netmock.setMocking',
        (method, parameters) async {
      _isMockingEnabled = parameters['enabled'] == 'true';
      return developer.ServiceExtensionResponse.result('{"result": "ok"}');
    });

    developer.registerExtension('netmock.setRecording',
        (method, parameters) async {
      _isRecording = parameters['enabled'] == 'true';
      return developer.ServiceExtensionResponse.result('{"result": "ok"}');
    });

    developer.registerExtension('netmock.updateMock',
        (method, parameters) async {
      final id = parameters['id'];
      final body = parameters['body'];
      if (id != null) {
        _mocks[id] = {'body': body};
      }
      return developer.ServiceExtensionResponse.result('{"result": "ok"}');
    });
  }

  Future<Map<String, dynamic>?> getMockedResponse({
    required String method,
    required String url,
  }) async {
    // Simple matching for now - exact URL match
    final key = '$method:$url';
    return _mocks[key];
  }

  void recordRequest({
    required String id,
    required String method,
    required String url,
    required Map<String, String> headers,
    String? body,
    required bool isMocked,
  }) {
    final request = {
      'id': id,
      'method': method,
      'url': url,
      'headers': headers,
      'requestBody': body,
      'timestamp': DateTime.now().toIso8601String(),
      'isMocked': isMocked,
    };

    _requests[id] = request;

    // Send to DevTools
    developer.postEvent('netmock.request', request);
  }

  void recordResponse({
    required String id,
    required int statusCode,
    required Map<String, String> headers,
    String? body,
    required Duration duration,
  }) {
    final request = _requests[id];
    if (request != null) {
      request['statusCode'] = statusCode;
      request['responseHeaders'] = headers;
      request['responseBody'] = body;
      request['duration'] = duration.inMilliseconds;

      // Update and send to DevTools
      developer.postEvent('netmock.request', request);
    }
  }
}
