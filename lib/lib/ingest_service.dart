// lib/ingest_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Simple holder for presigned response
class Presigned {
  final String uploadUrl; // PUT URL
  final String accessUrl; // GET URL with token/expiry
  Presigned({required this.uploadUrl, required this.accessUrl});
}

class IngestService {
  // TODO: replace with real endpoints
  final Uri schoolPresignEndpoint = Uri.parse('https://school.example.com/api/presign');
  final Uri relayIngest = Uri.parse('https://relay.example.com/ingest');

  // Demo secret: in production use device attestation or asymmetric keys
  final String relaySecret = 'very_strong_secret_demo';

  /// Request presigned URL from school backend (mocked here)
  Future<Presigned?> requestPresignedUrl() async {
    try {
      // Replace with real authenticated call to school backend.
      final uploadUrl = 'https://httpbin.org/put';
      final accessUrl = 'https://example.com/clip123?exp=1700000000';
      return Presigned(uploadUrl: uploadUrl, accessUrl: accessUrl);
    } catch (e) {
      return null;
    }
  }

  /// Upload bytes to presigned PUT URL
  Future<bool> uploadToPresigned(String presignedUrl, List<int> bytes) async {
    final uri = Uri.parse(presignedUrl);
    final resp = await http.put(uri,
        headers: {'Content-Type': 'application/octet-stream'}, body: bytes);
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  /// Compute HMAC-SHA256 hex
  String _computeHmac(String body, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(body);
    final digest = Hmac(sha256, key).convert(bytes);
    return digest.toString();
  }

  /// Send ingest to relay with x-signature header
  Future<http.Response> sendIngest(Map<String, dynamic> payload) async {
    final body = jsonEncode(payload);
    final sig = _computeHmac(body, relaySecret);
    final resp = await http.post(relayIngest,
        headers: {'Content-Type': 'application/json', 'x-signature': 'sha256=$sig'},
        body: body);
    return resp;
  }
}
