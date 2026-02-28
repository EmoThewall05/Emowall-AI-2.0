import 'package:flutter/material.dart';
import 'widgets/digital_watch.dart';

void main() {
  runApp(const DigitalWatchApp());
}

class DigitalWatchApp extends StatelessWidget {
  const DigitalWatchApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Watch',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const Scaffold(
        body: Center(child: DigitalWatch()),
      ),
    );
  }
}
