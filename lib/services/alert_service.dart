import 'dart:convert';
import 'package:http/http.dart' as http;

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  // 🔐 Set these in environment
  static const String _telegramBotToken = String.fromEnvironment('TELEGRAM_BOT_TOKEN');
  static const String _telegramChatId = String.fromEnvironment('TELEGRAM_CHAT_ID');
  static const String _discordWebhook = String.fromEnvironment('DISCORD_WEBHOOK_URL');

  // 🚨 Send to ALL channels simultaneously
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
              'color': 16711680, // Red
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
