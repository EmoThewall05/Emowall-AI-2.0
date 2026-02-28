// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'ingest_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emowall + Safety Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recReady = false;
  bool _recording = false;
  String _status = 'idle';
  final IngestService _ingest = IngestService();

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    _recReady = true;
    setState(() {});
  }

  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/clip_${DateTime.now().millisecondsSinceEpoch}.aac';
  }

  Future<void> _simulatePanic() async {
    if (!_recReady) return;
    final path = await _getTempFilePath();
    try {
      setState(() {
        _recording = true;
        _status = 'recording';
      });
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
        sampleRate: 16000,
      );
      await Future.delayed(const Duration(seconds: 8));
      await _recorder.stopRecorder();
      setState(() {
        _recording = false;
        _status = 'uploading';
      });

      final bytes = await File(path).readAsBytes();

      final presigned = await _ingest.requestPresignedUrl();
      if (presigned == null) {
        setState(() {
          _status = 'presign failed';
        });
        return;
      }

      final ok = await _ingest.uploadToPresigned(presigned.uploadUrl, bytes);
      if (!ok) {
        setState(() {
          _status = 'upload failed';
        });
        return;
      }

      final payload = {
        'incident_token': 'inc-${DateTime.now().millisecondsSinceEpoch}',
        'device_id': 'emowall-device-001',
        'signals': {
          'pulse': {'value': 120, 'quality': 0.85},
          'audio': {'cry': true, 'confidence': 0.88}
        },
        'coarse_location': {'lat': 25.276, 'lng': 55.296, 'precision_m': 100},
        'evidence_url': presigned.accessUrl,
        'timestamp': DateTime.now().toUtc().toIso8601String()
      };

      final resp = await _ingest.sendIngest(payload);
      if (resp.statusCode == 200) {
        setState(() {
          _status = 'sent';
        });
      } else {
        setState(() {
          _status = 'relay error: ${resp.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'error: $e';
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emowall + Safety Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Status: $_status'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _recording ? null : _simulatePanic,
              child: Text(_recording ? 'Recording...' : 'Simulate Panic Event'),
            ),
            const SizedBox(height: 12),
            const Text('This demo records a short clip, uploads to presigned URL, then posts signed metadata to relay.'),
          ],
        ),
      ),
    );
  }
}
