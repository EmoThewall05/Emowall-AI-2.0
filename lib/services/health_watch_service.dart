import 'package:health/health.dart';

/// Monitors heart rate via Health Connect to detect possible physical
/// distress (e.g. during a struggle/kidnap attempt) as one signal among
/// several used by Kidnap Mode. This does NOT diagnose any medical
/// condition — it only flags an abnormal reading to trigger extra
/// verification in the existing alert chain.
class HealthWatchService {
  static final HealthWatchService _instance = HealthWatchService._internal();
  factory HealthWatchService() => _instance;
  HealthWatchService._internal();

  final Health _health = Health();
  bool _monitoring = false;

  static const _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
  ];

  /// Must be called after the user has explicitly agreed to the
  /// in-app health disclaimer (see HealthConsentDialog).
  Future<bool> requestPermissions() async {
    try {
      await _health.configure();
      final granted = await _health.requestAuthorization(_types);
      return granted;
    } catch (e) {
      return false;
    }
  }

  /// Polls recent heart rate data and calls [onAbnormal] if a reading
  /// suggests possible distress (sustained high heart rate).
  /// This is a simple threshold signal, not a medical diagnosis.
  Future<void> startMonitoring({
    required void Function(String reason) onAbnormal,
  }) async {
    if (_monitoring) return;
    _monitoring = true;

    while (_monitoring) {
      try {
        final now = DateTime.now();
        final since = now.subtract(const Duration(minutes: 2));
        final data = await _health.getHealthDataFromTypes(
          types: _types,
          startTime: since,
          endTime: now,
        );

        for (final point in data) {
          if (point.type == HealthDataType.HEART_RATE) {
            final value = point.value;
            if (value is NumericHealthValue) {
              final bpm = value.numericValue.toDouble();
              // Sustained elevated heart rate can indicate physical
              // distress or a struggle. Threshold is intentionally
              // conservative to avoid false positives.
              if (bpm > 140) {
                onAbnormal(
                  'Elevated heart rate detected ($bpm bpm) — possible physical distress',
                );
              }
            }
          }
        }
      } catch (e) {
        // Silent fail — this is a supplementary signal, not the
        // primary detection method.
      }

      await Future.delayed(const Duration(seconds: 30));
    }
  }

  void stopMonitoring() {
    _monitoring = false;
  }
}
