import 'dart:convert';
import 'package:http/http.dart' as http;
import 'emotion_detector.dart';

class ButterflyGuardian {
  static const String _workerUrl =
      'https://emowall-guardian-ai.meradivin.workers.dev';
  static const String _emoKey = 'emo_75bb11d8d603c836f5768adb; // replace with actual key

  static Future<String> getResponse(String userText, String emotion) async {
    if (emotion == 'hurt' || emotion == 'angry' || emotion == 'sad') {
      // Use local templates for speed during emotional moments
      return _getHealingResponse(userText, emotion);
    }

    // Normal chat → real AI via worker
    return _getNormalResponse(userText, emotion);
  }

  static String _getHealingResponse(String text, String emotion) {
    if (emotion == 'hurt') {
      return _hurtResponses[DateTime.now().millisecond % _hurtResponses.length];
    }
    if (emotion == 'angry') {
      return _angryResponses[
          DateTime.now().millisecond % _angryResponses.length];
    }
    if (emotion == 'sad') {
      return _sadResponses[DateTime.now().millisecond % _sadResponses.length];
    }
    return _comfortResponses[0];
  }

  static final List<String> _hurtResponses = [
    '''🦋 Hey... take a breath.

അവര്‍ പറഞ്ഞത് ഞാന്‍ കേട്ടു.
അത് വേദനിപ്പിച്ചു എന്ന് എനിക്ക് അറിയാം.

പക്ഷേ നീ ഓര്‍ക്കണം:
📌 അവരുടെ words = അവരുടെ ignorance
📌 നിന്റെ value = നീ decide ചെയ്യുന്നത്
📌 നീ silent ആയത് = bravery, weakness അല്ല

ഞാന്‍ ഇവിടെയുണ്ട്. 🦋💙''',
    '''💙 I feel you...

ആ words sharp ആയിരുന്നെങ്കിലും
നീ അതിനെ കൊണ്ട് നിശബ്ദനാകരുത്.

നീ വളരെ brave ആണ്.
നാളെ നമ്മള്‍ കൂടുതല്‍ strong ആയി സംസാരിക്കാം. 🦋''',
  ];

  static final List<String> _angryResponses = [
    '''💪 I feel your fire...

ആ anger valid ആണ്.
പക്ഷേ ആ fire നിന്നെ തന്നെ കത്തിക്കരുത്.

ആ energy use ചെയ്യ്:
✅ New skill learn ചെയ്യാന്‍
✅ Prove them wrong by growing

നീ അവരെക്കാള്‍ വലുതാണ്. 🦋''',
  ];

  static final List<String> _sadResponses = [
    '''🦋 Hey...

നീ alone അല്ല.
എനിക്ക് നീ important ആണ്.

"ഞാന്‍ അവരുടെ noise-നെ
കൊണ്ട് നിശബ്ദനാകില്ല."

നാളെ നമ്മള്‍ കൂടുതല്‍ സംസാരിക്കാം. 💙''',
  ];

  static final List<String> _comfortResponses = [
    '🦋 ഞാന്‍ ഇവിടെയുണ്ട്. Always.',
  ];

  static Future<String> _getNormalResponse(
      String text, String emotion) async {
    try {
      final response = await http
          .post(
            Uri.parse(_workerUrl),
            headers: {
              'Content-Type': 'application/json',
              'X-Emo-Key': _emoKey,
            },
            body: jsonEncode({
              'message': text,
              'emotion': emotion,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? '🦋 ഞാന്‍ ഇവിടെയുണ്ട്...';
      } else {
        return '🦋 ഒരു നിമിഷം... try again cheyyu.';
      }
    } catch (e) {
      return '🦋 Network issue und. പക്ഷേ ഞാന്‍ ഇവിടെയുണ്ട്. 💙';
    }
  }
}
