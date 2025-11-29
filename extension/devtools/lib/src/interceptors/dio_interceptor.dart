import 'package:dio/dio.dart';
import '../netmock_client.dart';

class NetmockDioInterceptor extends Interceptor {
  final NetmockClient client;
  
  NetmockDioInterceptor(this.client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Check if we should mock this request
    if (client.isMockingEnabled) {
      final mockedResponse = await client.getMockedResponse(
        method: options.method,
        url: options.uri.toString(),
      );
      
      if (mockedResponse != null) {
        // Apply delay if configured
        if (mockedResponse['delay'] != null) {
          await Future.delayed(
            Duration(milliseconds: mockedResponse['delay'])
          );
        }
        
        handler.resolve(
          Response(
            requestOptions: options,
            data: mockedResponse['body'],
            statusCode: mockedResponse['statusCode'] ?? 200,
            headers: Headers.fromMap(mockedResponse['headers'] ?? {}),
          ),
        );
        
        // Record this as a mocked request
        client.recordRequest(
          id: requestId,
          method: options.method,
          url: options.uri.toString(),
          headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
          body: options.data?.toString(),
          isMocked: true,
        );
        return;
      }
    }
    
    // Record the request
    if (client.isRecording) {
      options.extra['netmock_id'] = requestId;
      options.extra['netmock_start'] = DateTime.now();
      
      client.recordRequest(
        id: requestId,
        method: options.method,
        url: options.uri.toString(),
        headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
        body: options.data?.toString(),
        isMocked: false,
      );
    }
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (client.isRecording) {
      final requestId = response.requestOptions.extra['netmock_id'];
      final startTime = response.requestOptions.extra['netmock_start'] as DateTime?;
      
      if (requestId != null) {
        client.recordResponse(
          id: requestId,
          statusCode: response.statusCode ?? 0,
          headers: response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
          body: response.data?.toString(),
          duration: startTime != null 
            ? DateTime.now().difference(startTime)
            : Duration.zero,
        );
      }
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (client.isRecording) {
      final requestId = err.requestOptions.extra['netmock_id'];
      final startTime = err.requestOptions.extra['netmock_start'] as DateTime?;
      
      if (requestId != null) {
        client.recordResponse(
          id: requestId,
          statusCode: err.response?.statusCode ?? 0,
          headers: err.response?.headers.map.map((k, v) => MapEntry(k, v.join(','))) ?? {},
          body: err.response?.data?.toString() ?? err.message ?? '',
          duration: startTime != null 
            ? DateTime.now().difference(startTime)
            : Duration.zero,
        );
      }
    }
    
    handler.next(err);
  }
}