/* ===== WATCH API ===== */
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Child's watch management via a server function that verifies the
/// Firebase login token (same pattern as ContactsApi).
class WatchApi {
  static const String _url =
      'https://eyonwjbwefdywqoywyif.supabase.co/functions/v1/watch-api';

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

  /// Returns {deviceId, pairCode, expiresAt}.
  static Future<Map<String, dynamic>> createDevice(String childName) =>
      _call({'action': 'create_device', 'childName': childName});

  static Future<List<Map<String, dynamic>>> list() async {
    final data = await _call({'action': 'list_devices'});
    return List<Map<String, dynamic>>.from(data['devices'] ?? []);
  }

  static Future<void> delete(String id) async {
    await _call({'action': 'delete_device', 'id': id});
  }
}
/* ===== END WATCH API ===== */
