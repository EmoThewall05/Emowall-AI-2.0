import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/time_service.dart';

class DigitalWatch extends StatefulWidget {
  const DigitalWatch({super.key});
  @override
  State<DigitalWatch> createState() => _DigitalWatchState();
}

class _DigitalWatchState extends State<DigitalWatch> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  bool _is24Hour = true;
  final TimeService _timeService = TimeService();

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timeText => _timeService.formatTime(_now, _is24Hour);
  String get _dateText => DateFormat('EEE, MMM d, y').format(_now);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_timeText,
            style: const TextStyle(
                fontSize: 72, fontWeight: FontWeight.w700, color: Colors.cyanAccent)),
        const SizedBox(height: 8),
        Text(_dateText, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => setState(() => _is24Hour = !_is24Hour),
              icon: Icon(_is24Hour ? Icons.schedule : Icons.access_time),
              label: Text(_is24Hour ? '24-hour' : '12-hour'),
            ),
            const SizedBox(width: 12),
            Chip(
              backgroundColor: Colors.white10,
              label: Text('TZ: ${_now.timeZoneName}', style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ],
    );
  }
}
