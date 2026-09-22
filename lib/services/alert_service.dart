import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  // 🔐 Set these in environment
  static const String _telegramBotToken = String.fromEnvironment('TELEGRAM_BOT_TOKEN');
  static const String _telegramChatId = String.fromEnvironment('TELEGRAM_CHAT_ID');
  static const String _discordWebhook = String.fromEnvironment('DISCORD_WEBHOOK_URL');

  // 🚨 Send to ALL channels simultaneously (Telegram + Discord + SMS via backend)
  Future<void> sendEmergencyAlert({
    required String childName,
    required String reason,
    required String location,
    required String country,
    required bool isFree,
  }) async {
    final message = _buildMessage(
      childName: childName,
      reason: reason,
      location: location,
      country: country,
      isFree: isFree,
    );

    // Send all simultaneously
    await Future.wait([
      _sendTelegram(message),
      _sendDiscord(message, reason),
      _sendSmsViaBackend(message),
    ]);
  }

  String _buildMessage({
    required String childName,
    required String reason,
    required String location,
    required String country,
    required bool isFree,
  }) {
    return '''
🚨 EMOWALL EMERGENCY ALERT 🚨
━━━━━━━━━━━━━━━━━━━━━
👤 Name: $childName
🌍 Country: $country
⚠️ Alert: $reason
📍 Location: $location
⏰ Time: ${DateTime.now().toUtc().toString().substring(0, 19)} UTC
${isFree ? '💚 Kerala Free Protection' : '🛡️ Emowall AI 2.0'}
━━━━━━━━━━━━━━━━━━━━━
🛡️ Emowall AI 2.0 — Protecting children in 177 countries
''';
  }

  // 📱 Telegram Alert
  Future<void> _sendTelegram(String message) async {
    if (_telegramBotToken.isEmpty || _telegramChatId.isEmpty) return;
    try {
      await http.post(
        Uri.parse('https://api.telegram.org/bot$_telegramBotToken/sendMessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': _telegramChatId,
          'text': message,
          'parse_mode': 'HTML',
        }),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Silent fail — other channels still work
    }
  }

  // 🎮 Discord Alert
  Future<void> _sendDiscord(String message, String reason) async {
    if (_discordWebhook.isEmpty) return;
    try {
      await http.post(
        Uri.parse(_discordWebhook),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'embeds': [
            {
              'title': '🚨 EMOWALL EMERGENCY',
              'description': message,
              'color': 16711680,
              'footer': {
                'text': 'Emowall AI 2.0 — 177 Countries Protection'
              },
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            }
          ]
        }),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Silent fail
    }
  }

  // 📩 SMS — now sent via a secure backend (Supabase Edge Function → Twilio).
  // No SEND_SMS permission needed on-device anymore.
  Future<void> _sendSmsViaBackend(String message) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken;

      await http.post(
        Uri.parse(
          'https://ovmjieytgtxlkvguughy.supabase.co/functions/v1/send-emergency-sms',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'firebase_uid': uid,
          'message': message,
        }),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      // Silent fail — Telegram/Discord channels still cover the alert
    }
  }

  // 📢 Send info alert (non-emergency)
  Future<void> sendInfoAlert(String message) async {
    await Future.wait([
      _sendTelegram(message),
      _sendDiscord(message, 'Info'),
    ]);
  }

  // 🌍 Country-specific police alert
  Future<void> alertLocalAuthorities({
    required String country,
    required String emergencyNumber,
    required String message,
  }) async {
    final countryAlert = '''
🚨 LOCAL AUTHORITY ALERT
Country: $country
Emergency: $message
Emowall AI 2.0 — Global Child Safety
''';
    await _sendTelegram(countryAlert);
    await _sendDiscord(countryAlert, 'Authority Alert');
  }
}
