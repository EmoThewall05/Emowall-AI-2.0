import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MediaVerifierScreen extends StatefulWidget {
  const MediaVerifierScreen({super.key});

  @override
  State<MediaVerifierScreen> createState() => _MediaVerifierScreenState();
}

class _MediaVerifierScreenState extends State<MediaVerifierScreen> {
  File? _selectedFile;
  bool _isImage = true;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  final ImagePicker _picker = ImagePicker();

  // Your Gemini API Key
  static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY';

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedFile = File(file.path);
        _isImage = true;
        _result = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedFile = File(file.path);
        _isImage = false;
        _result = null;
      });
    }
  }

  Future<void> _analyzeMedia() async {
    if (_selectedFile == null) return;
    setState(() => _isAnalyzing = true);

    try {
      final bytes = await _selectedFile!.readAsBytes();
      final base64Data = base64Encode(bytes);
      final mimeType = _isImage ? 'image/jpeg' : 'video/mp4';

      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$_geminiApiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': base64Data,
                  }
                },
                {
                  'text': '''
Analyze this ${_isImage ? 'image' : 'video'} and determine if it is:
1. REAL - Original, authentic, unedited
2. EDITED - Modified using tools like Photoshop, filters, cropping, color grading
3. AI_GENERATED - Created or manipulated by AI (Deepfake, Midjourney, DALL-E, Sora, etc.)

Respond ONLY in this exact JSON format:
{
  "verdict": "REAL" or "EDITED" or "AI_GENERATED",
  "confidence": 0-100,
  "reason": "one clear sentence explanation",
  "details": ["detail 1", "detail 2", "detail 3"]
}
'''
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        // Clean JSON from response
        final jsonStr = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final parsed = jsonDecode(jsonStr);
        setState(() => _result = parsed);
      }
    } catch (e) {
      setState(() => _result = {
        'verdict': 'ERROR',
        'confidence': 0,
        'reason': 'Analysis failed. Please try again.',
        'details': []
      });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Color _getVerdictColor(String? verdict) {
    switch (verdict) {
      case 'REAL': return const Color(0xFF00E5FF);
      case 'EDITED': return const Color(0xFFFFB800);
      case 'AI_GENERATED': return const Color(0xFFFF4444);
      default: return Colors.grey;
    }
  }

  IconData _getVerdictIcon(String? verdict) {
    switch (verdict) {
      case 'REAL': return Icons.verified;
      case 'EDITED': return Icons.edit;
      case 'AI_GENERATED': return Icons.smart_toy;
      default: return Icons.help;
    }
  }

  String _getVerdictLabel(String? verdict) {
    switch (verdict) {
      case 'REAL': return '✅ REAL — Original & Authentic';
      case 'EDITED': return '🟡 EDITED — Modified Content';
      case 'AI_GENERATED': return '🔴 AI GENERATED — Synthetic Media';
      default: return '❓ Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07080B),
        title: Text(
          '🔍 Media Verifier',
          style: GoogleFonts.syne(
            color: const Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00E5FF)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF7C3AED).withOpacity(0.1),
              ),
              child: Column(
                children: [
                  Text('AI Media Authentication',
                    style: GoogleFonts.syne(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                  const SizedBox(height: 8),
                  Text('Detect if image or video is Real, Edited, or AI Generated',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upload Buttons
            Row(
              children: [
                Expanded(
                  child: _buildUploadBtn(
                    '🖼️ Upload Image',
                    const Color(0xFF00E5FF),
                    _pickImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUploadBtn(
                    '🎬 Upload Video',
                    const Color(0xFF7C3AED),
                    _pickVideo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Preview
            if (_selectedFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isImage
                    ? Image.file(_selectedFile!, height: 220, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                        height: 120,
                        width: double.infinity,
                        color: const Color(0xFF1A1A2E),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.video_file, color: Color(0xFF7C3AED), size: 48),
                            const SizedBox(height: 8),
                            Text(_selectedFile!.path.split('/').last,
                              style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Analyze Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _analyzeMedia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isAnalyzing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                            SizedBox(width: 12),
                            Text('Analyzing with AI...'),
                          ],
                        )
                      : Text('🔍 ANALYZE NOW',
                          style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Result Card
            if (_result != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _getVerdictColor(_result!['verdict']),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: _getVerdictColor(_result!['verdict']).withOpacity(0.07),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verdict
                    Row(
                      children: [
                        Icon(_getVerdictIcon(_result!['verdict']),
                          color: _getVerdictColor(_result!['verdict']), size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_getVerdictLabel(_result!['verdict']),
                            style: GoogleFonts.syne(
                              color: _getVerdictColor(_result!['verdict']),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Confidence
                    Text('Confidence: ${_result!['confidence']}%',
                      style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (_result!['confidence'] as int) / 100,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getVerdictColor(_result!['verdict'])),
                    ),

                    const SizedBox(height: 16),

                    // Reason
                    Text('Analysis:', style: GoogleFonts.syne(
                      color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(_result!['reason'] ?? '',
                      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14)),

                    // Details
                    if (_result!['details'] != null &&
                        (_result!['details'] as List).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Details:', style: GoogleFonts.syne(
                        color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      ...(_result!['details'] as List).map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(
                              color: _getVerdictColor(_result!['verdict']))),
                            Expanded(child: Text(d.toString(),
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white70, fontSize: 13))),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(10),
          color: color.withOpacity(0.08),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.syne(
            color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ),
    );
  }
}
