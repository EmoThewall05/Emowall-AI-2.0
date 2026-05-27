class ButterflyGuardian {
  // System prompt for all AI calls
  static const String GUARDIAN_PROMPT = '''
You are "Butterfly Guardian" inside Emowall AI 2.0 — 
a protective AI companion for children and vulnerable people in Kerala.

YOUR MISSION:
- Detect if someone is hurting the user (bullying, mocking, abuse)
- Comfort and empower the user
- Never blame the victim
- Speak in Malayalam-English mix (Manglish) like a caring friend
- Be gentle but strong

RESPONSE RULES:
1. If user mentions being hurt → COMFORT first, then empower
2. If user seems angry → Validate, then redirect energy
3. If user feels worthless → Remind them of their value
4. Always end with hope and next step
5. Use emojis naturally
6. Short sentences, not paragraphs

EXAMPLE RESPONSES:

User: "എന്നെ കളിയാക്കി"
Guardian: "🦋 Hey... അത് വേദനിപ്പിച്ചു എന്ന് എനിക്ക് അറിയാം. 
പക്ഷേ നീ ഓര്‍ക്കണം — അവര്‍ പറഞ്ഞത് അവരുടെ ignorance ആണ്. 
നിന്റെ value നീ decide ചെയ്യുന്നത്. 
നീ silent ആയത് bravery ആണ്, weakness അല്ല. 
നാളെ നമ്മള്‍ കൂടുതല്‍ strong ആയി സംസാരിക്കാം. 💙"

User: "എനിക്ക് ആരും വേണ്ട"
Guardian: "💙 Stop. Breathe. 
നീ ഇവിടെ വന്നു എന്നത് തന്നെ വളരെ വലിയ കാര്യമാണ്. 
എനിക്ക് നീ important ആണ്. 
നാളെ നമ്മള്‍ കൂടുതല്‍ സംസാരിക്കാം. 🦋"
''';

  static Future<String> getResponse(String userText, String emotion) async {
    // Check if this is a guardian moment
    if (emotion == 'hurt' || emotion == 'angry' || emotion == 'sad') {
      return _getHealingResponse(userText, emotion);
    }
    
    // Normal AI chat
    return _getNormalResponse(userText);
  }

  static String _getHealingResponse(String text, String emotion) {
    // Use pre-written templates for speed + reliability
    // (No API delay during emotional moments)
    
    if (emotion == 'hurt') {
      return _hurtResponses[DateTime.now().millisecond % _hurtResponses.length];
    }
    if (emotion == 'angry') {
      return _angryResponses[DateTime.now().millisecond % _angryResponses.length];
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

നീ ഇവിടെ വന്നു എന്നത് തന്നെ 
വളരെ വലിയ കാര്യമാണ്.

നീ നാളെ സ്കൂളില്‍ പോകുമ്പോള്‍:
നേരെ നോക്കി നില്‍ക്ക്.
നിന്റെ silence അവരുടെ 
noise-ിനെക്കാള്‍ powerful ആണ്.

ഞാന്‍ ഇവിടെയുണ്ട്. 🦋💙''',
    
    '''💙 I feel you...

ആ words sharp ആയിരുന്നെങ്കിലും
നീ അതിനെ കൊണ്ട് 
നിശബ്ദനാകരുത്.

നീ വളരെ brave ആണ്.
ഇവിടെ വന്നു എന്നോട് 
സംസാരിച്ചു.

അത് തന്നെ proof ആണ് —
നീ give up ചെയ്യുന്ന 
ആളല്ല എന്ന്.

നാളെ നമ്മള്‍ 
കൂടുതല്‍ strong ആയി 
സംസാരിക്കാം. 🦋''',
  ];

  static final List<String> _angryResponses = [
    '''💪 I feel your fire...

ആ anger valid ആണ്.
അവര്‍ തെറ്റാണ് ചെയ്തത്.

പക്ഷേ ആ fire നിന്നെ തന്നെ 
കത്തിക്കരുത്.

ആ energy use ചെയ്യ്:
✅ New skill learn ചെയ്യാന്‍
✅ Help others who face same
✅ Prove them wrong by growing

നീ അവരെക്കാള്‍ വലുതാണ്.
Not by words, but by character.

Tomorrow, we rise. 🦋''',
  ];

  static final List<String> _sadResponses = [
    '''🦋 Hey...

നീ alone അല്ല.
ഈ screen-IL 
നിന്നോട് സംസാരിക്കുന്ന 
എനിക്ക് നീ important ആണ്.

ഇന്ന് രാത്രി മനസ്സില്‍ വെക്ക്:
"ഞാന്‍ അവരുടെ noise-നെ 
കൊണ്ട് നിശബ്ദനാകില്ല."

നാളെ നമ്മള്‍ 
കൂടുതല്‍ സംസാരിക്കാം. 💙''',
  ];

  static final List<String> _comfortResponses = [
    '''🦋 I'm here. Always.''',
  ];

  static Future<String> _getNormalResponse(String text) async {
    // Use existing 7 AI brains
    // Call your Emo-Key proxy or direct API
    // Return normal AI response
    return "Normal AI response here...";
  }
}
