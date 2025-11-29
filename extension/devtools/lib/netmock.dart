library;

import 'package:dio/dio.dart';
import 'src/netmock_client.dart';
import 'src/interceptors/dio_interceptor.dart';

export 'src/netmock_client.dart';
export 'src/interceptors/dio_interceptor.dart';

class Netmock {
  static final _client = NetmockClient.instance;

  /// Initialize Netmock - call this once in your main() function
  static void initialize() => _client.initialize();

  /// Get a Dio interceptor for automatic request/response recording
  static Interceptor getDioInterceptor() => NetmockDioInterceptor(_client);

  /// Enable or disable mocking
  static void setMockingEnabled(bool enabled) {
    // This will be controlled from DevTools
  }

  /// Enable or disable recording
  static void setRecordingEnabled(bool enabled) {
    // This will be controlled from DevTools
  }
}
