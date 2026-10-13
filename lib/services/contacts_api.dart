import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Emergency contacts via a server function that verifies the Firebase
/// login token, so users can only ever access their own contacts.
class ContactsApi {
  static const String _url =
      'https://eyonwjbwefdywqoywyif.supabase.co/functions/v1/contacts-api';

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

  static Future<List<Map<String, dynamic>>> list() async {
    final data = await _call({'action': 'list'});
    return List<Map<String, dynamic>>.from(data['contacts'] ?? []);
  }

  static Future<void> add(
      {required String name, required String relation, required String phone}) async {
    await _call({'action': 'add', 'name': name, 'relation': relation, 'phone': phone});
  }

  static Future<void> update(String id,
      {required String name, required String relation, required String phone}) async {
    await _call({'action': 'update', 'id': id, 'name': name, 'relation': relation, 'phone': phone});
  }

  static Future<void> delete(String id) async {
    await _call({'action': 'delete', 'id': id});
  }
}
