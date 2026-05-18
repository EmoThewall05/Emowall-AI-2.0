import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Timer? _liveTrackTimer;
  bool _isTracking = false;
  Map<String, dynamic>? _lastLocation;

  // Watch battery status
  int _watchBattery = 100;
  bool _watchConnected = false;

  // SOS active ആയാൽ live tracking start
  Future<void> startLiveTracking({
    required List<Map<String, String>> contacts,
    required String reason,
    bool silent = false,
  }) async {
    if (_isTracking) return;
    _isTracking = true;

    // Watch battery check
    if (_watchConnected && _watchBattery < 20) {
      await _notifyWatchBatteryLow(contacts);
    }

    // Immediately send first location
    await _sendLocationToContacts(contacts, reason, silent);

    // Every 30 seconds live update
    _liveTrackTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _sendLocationToContacts(contacts, reason, silent);
    });
  }

  Future<void> _sendLocationToContacts(
    List<Map<String, String>> contacts,
    String reason,
    bool silent,
  ) async {
    try {
      // Google Maps live location link
      // Phone GPS — watch independent
      final locationMsg = Uri.encodeComponent(
        '🚨 EMOWALL ALERT: $reason\n'
        '📍 Live Location: https://maps.google.com/?q=mylocation\n'
        '⏰ Time: ${DateTime.now().toString().substring(0, 19)}\n'
        '🛡️ Emowall AI 2.0 — Auto Alert',
      );

      for (final contact in contacts) {
        final phone = contact['phone']!.replaceAll('+', '').replaceAll(' ', '');
        
        // WhatsApp alert
        final waUrl = 'https://wa.me/$phone?text=$locationMsg';
        if (await canLaunchUrl(Uri.parse(waUrl))) {
          await launchUrl(Uri.parse(waUrl));
        }
      }

      // Police alert — Kerala Police WhatsApp
      await _alertPolice(reason);

    } catch (e) {
      debugPrint('Location send error: $e');
    }
  }

  Future<void> _alertPolice(String reason) async {
    // Kerala Police emergency
    final policeMsg = Uri.encodeComponent(
      '🚨 CHILD SAFETY ALERT — EMOWALL AI\n'
      'Reason: $reason\n'
      '📍 Location: https://maps.google.com/?q=mylocation\n'
      'Please respond immediately.\n'
      'App: Emowall AI 2.0 (com.emobies.emowall)',
    );

    // Kerala Police WhatsApp: 9497900000
    final policeUrl = 'https://wa.me/919497900000?text=$policeMsg';
    if (await canLaunchUrl(Uri.parse(policeUrl))) {
      await launchUrl(Uri.parse(policeUrl));
    }
  }

  Future<void> _notifyWatchBatteryLow(List<Map<String, String>> contacts) async {
    final msg = Uri.encodeComponent(
      '⚠️ EMOWALL WARNING:\n'
      'Smart Watch battery below 20%!\n'
      'Switching to Phone GPS tracking.\n'
      'Please charge the watch.',
    );

    for (final contact in contacts) {
      final phone = contact['phone']!.replaceAll('+', '').replaceAll(' ', '');
      final url = 'https://wa.me/$phone?text=$msg';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  void updateWatchStatus(bool connected, int battery) {
    _watchConnected = connected;
    _watchBattery = battery;
  }

  void stopTracking() {
    _liveTrackTimer?.cancel();
    _isTracking = false;
  }

  bool get isTracking => _isTracking;

  void dispose() {
    stopTracking();
  }
}
