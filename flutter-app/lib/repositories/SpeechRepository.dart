import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/SpeechRequest.dart';

class SpeechRepository {
  static const String speechRequestsKey = 'speech_requests';

  Future<List<SpeechRequest>> loadRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(speechRequestsKey);
    if (data == null) return [];
    final List<dynamic> jsonData = json.decode(data);
    return jsonData.map((item) => SpeechRequest.fromJson(item)).toList();
  }

  Future<void> saveRequests(List<SpeechRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(requests.map((r) => r.toJson()).toList());
    await prefs.setString(speechRequestsKey, jsonString);
  }
}