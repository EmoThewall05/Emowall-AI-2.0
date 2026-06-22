import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../services/alert_service.dart';

class AnimalAlertScreen extends StatefulWidget {
  const AnimalAlertScreen({super.key});
  @override
  State<AnimalAlertScreen> createState() => _AnimalAlertScreenState();
}

class _AnimalAlertScreenState extends State<AnimalAlertScreen> {
  static const String _workerUrl =
      'https://emowall-animal-alert.meradivin.workers.dev';
  static const String _emoKey = 'YOUR_EMO_KEY_HERE';

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;
  bool _scanning = false;
  Map<String, dynamic>? _scanResult;
  String _status = 'Camera ready — Point at animal or insect';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (e) {
      setState(() => _status = 'Camera error: $e');
    }
  }

  Future<void> _scanAnimal() async {
    if (!_cameraReady || _scanning) return;
    setState(() {
      _scanning = true;
      _scanResult = null;
      _status = 'Scanning... AI analyzing...';
    });

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_workerUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Emo-Key': _emoKey,
        },
        body: jsonEncode({
          'imageBase64': base64Image,
          'mimeType': 'image/jpeg',
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _scanResult = result;
          _status = result['detected'] == true
              ? '${result["species"]} detected!'
              : 'No dangerous animal detected';
        });
      } else {
        setState(() => _status = 'Scan failed. Try again.');
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _scanning = false);
    }
  }

  Future<void> _triggerAttackAlert() async {
    HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.alert);

    final alertService = AlertService();
    final species = _scanResult?['species'] ?? 'unknown animal';
    final firstAid = _scanResult?['firstAid'] ?? 'Seek immediate medical help.';
    final urgent = _scanResult?['hospitalUrgency'] ?? 'immediate';

    await alertService.sendEmergencyAlert(
      childName: 'User',
      reason: 'Animal Attack — $species. First Aid: $firstAid. Hospital urgency: $urgent.',
      location: 'Live GPS Active',
      country: 'India',
      isFree: true,
    );
  }

  Color _dangerColor(String? level) {
    switch (level) {
      case 'high': return const Color(0xFFEF4444);
      case 'medium': return const Color(0xFFF59E0B);
      case 'low': return const Color(0xFF3B82F6);
      default: return const Color(0xFF00E676);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0F14),
        title: Text(
          '🐾 Animal Alert',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // Camera Preview
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF111519),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2A35)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _cameraReady && _cameraController != null
                  ? CameraPreview(_cameraController!)
                  : Center(
                      child: Text(
                        '📷 Initializing camera...',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF8892A4),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111519),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E2A35)),
            ),
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: const Color(0xFF8892A4),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Scan Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00d4aa),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _scanning ? null : _scanAnimal,
              icon: _scanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.camera_alt, color: Colors.black),
              label: Text(
                _scanning ? 'Scanning...' : '🔍 Scan Animal / Insect',
                style: GoogleFonts.syne(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Scan Result
          if (_scanResult != null && _scanResult!['detected'] == true) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111519),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _dangerColor(_scanResult!['dangerLevel']).withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(children: [
                  Expanded(
                    child: Text(
                      _scanResult!['species'] ?? 'Unknown',
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _dangerColor(_scanResult!['dangerLevel']).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _dangerColor(_scanResult!['dangerLevel'])),
                    ),
                    child: Text(
                      (_scanResult!['dangerLevel'] ?? 'unknown').toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: _dangerColor(_scanResult!['dangerLevel']),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 8),
                Text(
                  _scanResult!['dangerDescription'] ?? '',
                  style: GoogleFonts.syne(fontSize: 13, color: Colors.white70),
                ),

                const Divider(color: Color(0xFF1E2A35), height: 24),

                Text('⚡ Immediate Action',
                    style: GoogleFonts.syne(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFBBF24),
                    )),
                const SizedBox(height: 6),
                Text(
                  _scanResult!['immediateAction'] ?? '',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12, color: Colors.white70, height: 1.5,
                  ),
                ),

                const Divider(color: Color(0xFF1E2A35), height: 24),

                Text('🩹 First Aid',
                    style: GoogleFonts.syne(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00d4aa),
                    )),
                const SizedBox(height: 6),
                Text(
                  _scanResult!['firstAid'] ?? '',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12, color: Colors.white70, height: 1.5,
                  ),
                ),

                const Divider(color: Color(0xFF1E2A35), height: 24),

                Row(children: [
                  const Icon(Icons.local_hospital, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Hospital: ${(_scanResult!['hospitalUrgency'] ?? '').replaceAll('_', ' ').toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),

                if (_scanResult!['antivenomNeeded'] == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.warning, color: Color(0xFFEF4444), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ANTIVENOM REQUIRED — Rush to hospital immediately!',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: const Color(0xFFEF4444),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ]),
            ),

            const SizedBox(height: 16),

            // Attack SOS Button
            GestureDetector(
              onLongPress: _triggerAttackAlert,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEF4444), width: 2),
                ),
                child: Column(children: [
                  const Icon(Icons.sos, color: Color(0xFFEF4444), size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'HOLD — I AM BEING ATTACKED',
                    style: GoogleFonts.syne(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Triggers loud alert + contacts + emergency services',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
                ]),
              ),
            ),
          ],

          if (_scanResult != null && _scanResult!['detected'] == false) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
              ),
              child: Column(children: [
                const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 40),
                const SizedBox(height: 8),
                Text(
                  'No dangerous animal detected',
                  style: GoogleFonts.syne(
                    color: const Color(0xFF00E676),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay alert and scan again if needed',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ]),
            ),
          ],

          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}
