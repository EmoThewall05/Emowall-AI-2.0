import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// SOS events via a server function that verifies the Firebase login.
/// The server sends the SMS alerts, so nothing depends on the phone's screen.
class SosApi {
  static const String _url =
      'https://eyonwjbwefdywqoywyif.supabase.co/functions/v1/sos-api';

  static String? currentEventId;

  static Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');
    final token = await user.getIdToken();
    final res = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['error'] ?? 'Request failed (${res.statusCode})');
    }
    return data;
  }

  static Future<String> start({
    required String reason,
    required String childName,
    double? lat,
    double? lng,
  }) async {
    final data = await _call({
      'action': 'start',
      'reason': reason,
      'childName': childName,
      'lat': lat,
      'lng': lng,
    });
    final id = data['eventId'] as String;
    currentEventId = id;
    return id;
  }

  static Future<Map<String, dynamic>> notify({
    required String eventId,
    String? contactId,
    bool all = false,
    required String childName,
    double? lat,
    double? lng,
  }) =>
      _call({
        'action': 'notify',
        'eventId': eventId,
        'contactId': contactId,
        'all': all,
        'childName': childName,
        'lat': lat,
        'lng': lng,
      });

  static Future<String> status(String eventId) async {
    final data = await _call({'action': 'status', 'eventId': eventId});
    return (data['status'] ?? 'active') as String;
  }

  static Future<void> updateLocation({
    required String eventId,
    required double lat,
    required double lng,
  }) async {
    await _call({'action': 'location', 'eventId': eventId, 'lat': lat, 'lng': lng});
  }

  static Future<void> markSafe(String eventId) async {
    await _call({'action': 'safe', 'eventId': eventId});
  }

  static Future<void> close(String eventId) async {
    await _call({'action': 'close', 'eventId': eventId});
  }
}
