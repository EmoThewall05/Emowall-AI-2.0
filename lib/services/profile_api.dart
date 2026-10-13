import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Profile photo upload via a server function that verifies the
/// Firebase login token. Users can only write to their own folder.
class ProfileApi {
  static const String _url =
      'https://eyonwjbwefdywqoywyif.supabase.co/functions/v1/avatar-upload';

  static Future<void> uploadAvatar(Uint8List bytes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not signed in');
    final token = await user.getIdToken();
    final res = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Content-Type': 'image/jpeg',
            'Authorization': 'Bearer $token',
          },
          body: bytes,
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw Exception('Upload failed (${res.statusCode}): ${res.body}');
    }
  }
}
