class NetworkRequest {
  final String id;
  final String method;
  final String url;
  final Map<String, String> headers;
  final String? requestBody;
  final int statusCode;
  final String? responseBody;
  final Map<String, String> responseHeaders;
  final DateTime timestamp;
  final Duration duration;
  String? mockedResponseBody;
  bool isMocked;

  NetworkRequest({
    required this.id,
    required this.method,
    required this.url,
    required this.headers,
    this.requestBody,
    required this.statusCode,
    this.responseBody,
    required this.responseHeaders,
    required this.timestamp,
    required this.duration,
    this.mockedResponseBody,
    this.isMocked = false,
  });

  factory NetworkRequest.fromJson(Map<String, dynamic> json) {
    return NetworkRequest(
      id: json['id'] ?? '',
      method: json['method'] ?? '',
      url: json['url'] ?? '',
      headers: Map<String, String>.from(json['headers'] ?? {}),
      requestBody: json['requestBody'],
      statusCode: json['statusCode'] ?? 0,
      responseBody: json['responseBody'],
      responseHeaders: Map<String, String>.from(json['responseHeaders'] ?? {}),
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      duration: Duration(milliseconds: json['duration'] ?? 0),
      isMocked: json['isMocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'url': url,
        'headers': headers,
        'requestBody': requestBody,
        'statusCode': statusCode,
        'responseBody': responseBody,
        'responseHeaders': responseHeaders,
        'timestamp': timestamp.toIso8601String(),
        'duration': duration.inMilliseconds,
        'mockedResponseBody': mockedResponseBody,
        'isMocked': isMocked,
      };
}
