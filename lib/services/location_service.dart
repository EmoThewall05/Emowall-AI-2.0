import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'sos_api.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Timer? _liveTrackTimer;
  bool _isTracking = false;

  // Watch status (kept for the existing UI)
  int _watchBattery = 100;
  bool _watchConnected = false;

  /// Real GPS position, or null if permission/service is unavailable.
  Future<Position?> currentPosition() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// While an SOS event is active, keep its location fresh on the server.
  /// Contacts open one link and always see the latest position.
  Future<void> startLiveTracking({
    required List<Map<String, String>> contacts,
    required String reason,
    bool silent = false,
  }) async {
    if (_isTracking) return;
    _isTracking = true;
    await _pushLocation();
    _liveTrackTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _pushLocation();
    });
  }

  Future<void> _pushLocation() async {
    final id = SosApi.currentEventId;
    if (id == null) return;
    final pos = await currentPosition();
    if (pos == null) return;
    try {
      await SosApi.updateLocation(
          eventId: id, lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      debugPrint('Location update failed: $e');
    }
  }

  void updateWatchStatus(bool connected, int battery) {
    _watchConnected = connected;
    _watchBattery = battery;
  }

  void stopTracking() {
    _liveTrackTimer?.cancel();
    _liveTrackTimer = null;
    _isTracking = false;
  }

  bool get isTracking => _isTracking;
  bool get watchConnected => _watchConnected;
  int get watchBattery => _watchBattery;

  void dispose() {
    stopTracking();
  }
}
