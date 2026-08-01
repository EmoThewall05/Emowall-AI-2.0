class EmotionDetector {
  static String detect(String text) {
    String lower = text.toLowerCase();
    
    // Hurt indicators
    List<String> hurtWords = [
      'കളി', 'വെറും', 'അസംഭവ്യം', 'stupid', 'idiot',
      'ആരും ഇഷ്ടപ്പെടുന്നില്ല', 'alone', 'worthless',
      'മരിക്കണം', 'give up', 'no one cares',
      'ചെറിയവന്‍', 'പാവം', 'വികലം', 'mute',
      'mock', 'laugh', 'tease', 'bully',
      'hurt', 'pain', 'cry', 'sad',
    ];
    
    // Anger indicators
    List<String> angerWords = [
      'കോപം', 'പക', 'revenge', 'kill', 'hurt them',
      'angry', 'hate', 'destroy', 'kill them',
    ];
    
    // Sad indicators
    List<String> sadWords = [
      'ദുഃഖം', 'നിരാശ', 'useless', 'failure',
      'sad', 'depressed', 'hopeless', 'worthless',
    ];
    
    for (String word in hurtWords) {
      if (lower.contains(word)) return 'hurt';
    }
    
    for (String word in angerWords) {
      if (lower.contains(word)) return 'angry';
    }
    
    for (String word in sadWords) {
      if (lower.contains(word)) return 'sad';
    }
    
    return 'neutral';
  }
}
