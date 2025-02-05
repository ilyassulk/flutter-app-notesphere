/// Модель для запроса Speech-to-Text
class SpeechRequest {
  final String requestId;
  String status; // "wait", "proc", "ok", "err"
  String? result;
  String? error;

  SpeechRequest({
    required this.requestId,
    required this.status,
    this.result,
    this.error,
  });

  factory SpeechRequest.fromJson(Map<String, dynamic> json) => SpeechRequest(
    requestId: json['request_id'],
    status: json['status'],
    result: json['result'],
    error: json['error'],
  );

  Map<String, dynamic> toJson() => {
    'request_id': requestId,
    'status': status,
    'result': result,
    'error': error,
  };
}