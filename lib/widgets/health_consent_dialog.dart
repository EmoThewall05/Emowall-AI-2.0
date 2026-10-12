import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shown once before requesting Health Connect permissions.
/// Not a medical device — heart rate is used only as one supplementary
/// signal to detect possible physical distress during Kidnap Mode.
class HealthConsentDialog extends StatelessWidget {
  const HealthConsentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111519),
      title: Text('❤️ Heart Rate Monitoring',
          style: GoogleFonts.syne(
              color: Colors.white, fontWeight: FontWeight.w800)),
      content: Text(
        'Emowall is not a medical device and does not diagnose any '
        'health condition.\n\n'
        'With your permission, it can read heart rate and blood oxygen '
        'data via Health Connect from your phone or smartwatch. This is '
        'used only as one additional signal — alongside sound and '
        'location — to detect possible physical distress during Kidnap '
        'Mode (for example, a sustained abnormal heart rate).\n\n'
        'This data stays on your device and is never uploaded to our '
        'servers, except as part of an emergency alert you or the app '
        'has triggered.',
        style: GoogleFonts.jetBrainsMono(
            fontSize: 12, color: Colors.white70, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Not now', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676)),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Allow', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
