/// Telegram/Discord channels removed: child data must not go to third-party
/// chat services. Real emergency delivery is done by the server via SosApi
/// (Supabase sos-api -> Twilio SMS). Kept as a no-op for existing callers.
class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  Future<void> sendEmergencyAlert({
    required String childName,
    required String reason,
    required String location,
    required String country,
    required bool isFree,
  }) async {}

  Future<void> sendInfoAlert(String message) async {}
}
