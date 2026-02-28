import 'package:intl/intl.dart';

class TimeService {
  String formatTime(DateTime dt, bool is24Hour) {
    if (is24Hour) {
      return DateFormat('HH:mm:ss').format(dt);
    } else {
      return DateFormat('hh:mm:ss a').format(dt);
    }
  }
}
