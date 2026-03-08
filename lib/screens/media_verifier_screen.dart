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

class _MediaVerifierScreenState extends State<MediaVerifierScreen>
    with TickerProviderStateMixin {
  File? _selectedFile;
  bool _isImage = true;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ✅ Replace with your actual Gemini API Key
  static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────── PICK IMAGE ───────────
  Future<void> _pickImage() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() {
        _selectedFile = File(file.path);
        _isImage = true;
        _result = null;
      });
    }
  }

  // ─────────── PICK VIDEO ───────────
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

  // ─────────── CAMERA IMAGE ───────────
  Future<void> _captureImage() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file != null) {
      setState(() {
        _selectedFile = File(file.path);
        _isImage = true;
        _result = null;
      });
    }
  }

  // ─────────── ANALYZE ───────────
  Future<void> _analyzeMedia() async {
    if (_selectedFile == null) return;
    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    try {
      final bytes = await _selectedFile!.readAsBytes();

      // Limit file size: max 10MB for API
      if (bytes.lengthInBytes > 10 * 1024 * 1024) {
        setState(() {
          _result = {
            'verdict': 'ERROR',
            'confidence': 0,
            'reason': 'File too large. Please select a file under 10MB.',
            'details': [],
          };
        });
        return;
      }

      final base64Data = base64Encode(bytes);
      final mimeType = _isImage ? 'image/jpeg' : 'video/mp4';

      final response = await http
          .post(
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
You are an expert AI media forensics analyst.

Carefully analyze this ${_isImage ? 'image' : 'video'} and determine EXACTLY which ONE of these categories it belongs to:

1. REAL — Authentic, original, unedited content captured by a camera
2. EDITED — Real content that has been modified (Photoshop, filters, color grading, cropping, compositing, face swap on real image, object removal, etc.)
3. AI_GENERATED — Entirely or mostly created by AI tools (Midjourney, DALL-E, Stable Diffusion, Sora, DeepFake video, GAN-generated faces, etc.)

Look for these forensic clues:
- Unnatural lighting, shadows, or reflections
- Blurry or distorted edges, especially around faces or hair
- Inconsistent textures or patterns
- Metadata anomalies (if available)
- AI artifacts: overly smooth skin, strange backgrounds, impossible details
- Deepfake indicators: unnatural eye movement, blinking, lip sync issues (for video)
- Compression artifacts inconsistent with stated source

Respond ONLY in this exact JSON format, nothing else:
{
  "verdict": "REAL" or "EDITED" or "AI_GENERATED",
  "confidence": <integer 0-100>,
  "reason": "<one clear sentence summary of your finding>",
  "details": [
    "<specific forensic observation 1>",
    "<specific forensic observation 2>",
    "<specific forensic observation 3>"
  ]
}
'''
                    }
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.1,
                'maxOutputTokens': 500,
              }
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Clean JSON from response
        String jsonStr = text
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        // Extract JSON object if extra text
        final startIndex = jsonStr.indexOf('{');
        final endIndex = jsonStr.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1) {
          jsonStr = jsonStr.substring(startIndex, endIndex + 1);
        }

        final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
        setState(() => _result = parsed);
      } else {
        setState(() => _result = {
              'verdict': 'ERROR',
              'confidence': 0,
              'reason':
                  'API error ${response.statusCode}. Please check your API key.',
              'details': [],
            });
      }
    } catch (e) {
      setState(() => _result = {
            'verdict': 'ERROR',
            'confidence': 0,
            'reason': 'Analysis failed. Please try again.',
            'details': [e.toString()],
          });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  // ─────────── HELPERS ───────────
  Color _getVerdictColor(String? verdict) {
    switch (verdict) {
      case 'REAL':
        return const Color(0xFF00E5FF);
      case 'EDITED':
        return const Color(0xFFFFB800);
      case 'AI_GENERATED':
        return const Color(0xFFFF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getVerdictIcon(String? verdict) {
    switch (verdict) {
      case 'REAL':
        return Icons.verified_rounded;
      case 'EDITED':
        return Icons.auto_fix_high_rounded;
      case 'AI_GENERATED':
        return Icons.smart_toy_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getVerdictEmoji(String? verdict) {
    switch (verdict) {
      case 'REAL':
        return '✅';
      case 'EDITED':
        return '🟡';
      case 'AI_GENERATED':
        return '🔴';
      default:
        return '❓';
    }
  }

  String _getVerdictTitle(String? verdict) {
    switch (verdict) {
      case 'REAL':
        return 'REAL — Original & Authentic';
      case 'EDITED':
        return 'EDITED — Modified Content';
      case 'AI_GENERATED':
        return 'AI GENERATED — Synthetic Media';
      default:
        return 'Analysis Error';
    }
  }

  String _getVerdictDescription(String? verdict) {
    switch (verdict) {
      case 'REAL':
        return 'This content appears to be authentic and unmodified.';
      case 'EDITED':
        return 'This content shows signs of editing or manipulation.';
      case 'AI_GENERATED':
        return 'This content appears to be created or manipulated by AI.';
      default:
        return 'Could not determine authenticity.';
    }
  }

  // ─────────── BUILD ───────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07080B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF00E5FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '🔍 Media Verifier',
          style: GoogleFonts.syne(
            color: const Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFF7C3AED).withOpacity(0.3),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER CARD ──
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // ── UPLOAD OPTIONS ──
            Text(
              'SELECT MEDIA',
              style: GoogleFonts.syne(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            _buildUploadOptions(),
            const SizedBox(height: 24),

            // ── PREVIEW ──
            if (_selectedFile != null) ...[
              Text(
                'SELECTED FILE',
                style: GoogleFonts.syne(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _buildPreview(),
              const SizedBox(height: 20),
              _buildAnalyzeButton(),
              const SizedBox(height: 24),
            ],

            // ── RESULT ──
            if (_isAnalyzing) _buildAnalyzingCard(),
            if (_result != null && !_isAnalyzing) _buildResultCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── HEADER CARD ──
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C3AED).withOpacity(0.15),
            const Color(0xFF00E5FF).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(0.4), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image_search_rounded,
                    color: Color(0xFF7C3AED), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Media Authentication',
                      style: GoogleFonts.syne(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Powered by Gemini Vision AI',
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFF7C3AED),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge('✅ REAL', const Color(0xFF00E5FF)),
              const SizedBox(width: 8),
              _buildBadge('🟡 EDITED', const Color(0xFFFFB800)),
              const SizedBox(width: 8),
              _buildBadge('🔴 AI GEN', const Color(0xFFFF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.syne(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── UPLOAD OPTIONS ──
  Widget _buildUploadOptions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildUploadTile(
                icon: Icons.photo_library_rounded,
                label: 'Gallery\nImage',
                color: const Color(0xFF00E5FF),
                onTap: _pickImage,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildUploadTile(
                icon: Icons.camera_alt_rounded,
                label: 'Camera\nPhoto',
                color: const Color(0xFF7C3AED),
                onTap: _captureImage,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildUploadTile(
                icon: Icons.video_library_rounded,
                label: 'Gallery\nVideo',
                color: const Color(0xFFFF4FA3),
                onTap: _pickVideo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          border: Border.all(color: color.withOpacity(0.4), width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.syne(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PREVIEW ──
  Widget _buildPreview() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: _isImage
            ? Image.file(
                _selectedFile!,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : Container(
                height: 140,
                color: const Color(0xFF0D0D1A),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.video_file_rounded,
                        color: Color(0xFFFF4FA3), size: 52),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFile!.path.split('/').last,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_selectedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── ANALYZE BUTTON ──
  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _analyzeMedia,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFF00E5FF).withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          '🔍  ANALYZE WITH AI',
          style: GoogleFonts.syne(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ── ANALYZING CARD ──
  Widget _buildAnalyzingCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF7C3AED),
                  strokeWidth: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Analyzing with Gemini AI...',
                  style: GoogleFonts.syne(
                    color: const Color(0xFF7C3AED),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Checking for forensic anomalies',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── RESULT CARD ──
  Widget _buildResultCard() {
    final verdict = _result!['verdict'] as String?;
    final confidence = (_result!['confidence'] as num?)?.toInt() ?? 0;
    final reason = _result!['reason'] as String? ?? '';
    final details = (_result!['details'] as List?)?.cast<String>() ?? [];
    final color = _getVerdictColor(verdict);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verdict Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getVerdictIcon(verdict), color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getVerdictEmoji(verdict)} ${_getVerdictTitle(verdict)}',
                      style: GoogleFonts.syne(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getVerdictDescription(verdict),
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),

          // Confidence Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Confidence',
                style: GoogleFonts.syne(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              Text(
                '$confidence%',
                style: GoogleFonts.syne(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 20),

          // Reason
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Colors.white38, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    reason,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          if (details.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'FORENSIC DETAILS',
              style: GoogleFonts.syne(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            ...details.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        d,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Re-analyze button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _result = null;
                  _selectedFile = null;
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color.withOpacity(0.5)),
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Verify Another Media',
                style: GoogleFonts.syne(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
