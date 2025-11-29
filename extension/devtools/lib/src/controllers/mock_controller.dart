import 'package:flutter/foundation.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import '../models/network_request.dart';

class MockController extends ChangeNotifier {
  final List<NetworkRequest> _requests = [];
  NetworkRequest? _selectedRequest;
  bool _isMockingEnabled = false;
  bool _isRecording = true;

  List<NetworkRequest> get requests => List.unmodifiable(_requests);
  NetworkRequest? get selectedRequest => _selectedRequest;
  bool get isMockingEnabled => _isMockingEnabled;
  bool get isRecording => _isRecording;

  void initialize() async => await _setupServiceExtensions();

  Future<void> _setupServiceExtensions() async {
    // Listen for requests from the app
    serviceManager.service?.onExtensionEvent.listen((event) {
      if (event.extensionKind == 'netmock.request') {
        _handleNetworkRequest(event.extensionData?.data ?? {});
      }
    });
  }

  void _handleNetworkRequest(Map<String, dynamic> data) {
    final request = NetworkRequest.fromJson(data);
    _requests.add(request);
    notifyListeners();
  }

  void selectRequest(NetworkRequest request) {
    _selectedRequest = request;
    notifyListeners();
  }

  void toggleMocking() {
    _isMockingEnabled = !_isMockingEnabled;
    _sendToApp('netmock.setMocking', {'enabled': _isMockingEnabled});
    notifyListeners();
  }

  void toggleRecording() {
    _isRecording = !_isRecording;
    _sendToApp('netmock.setRecording', {'enabled': _isRecording});
    notifyListeners();
  }

  void clearAll() {
    _requests.clear();
    _selectedRequest = null;
    notifyListeners();
  }

  void updateMockedResponse(
    NetworkRequest request, {
    required String newBody,
    required int statusCode,
    required int delay,
  }) {
    request.mockedResponseBody = newBody;
    // We don't store status code/delay on the request object for display yet,
    // as those are "mock settings" separate from the original request.
    // But we send them to the app.

    _sendToApp('netmock.updateMock', {
      'id': request.id,
      'body': newBody,
      'statusCode': statusCode,
      'delay': delay,
    });
    notifyListeners();
  }

  void _sendToApp(String method, Map<String, dynamic> args) {
    serviceManager.service?.callServiceExtension(
      method,
      isolateId: serviceManager.isolateManager.selectedIsolate.value?.id,
      args: args,
    );
  }
}
