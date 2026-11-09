import 'package:flutter/material.dart';
import 'emo_care_service.dart';
import 'emotion_detector.dart';

class EmoCareScreen extends StatefulWidget {
  @override
  EmoCareScreenState createState() => EmoCareScreenState();
}

class EmoCareScreenState extends State<EmoCareScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> messages = [];
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  // ===== TYPING INDICATOR STATE =====
  bool _isTyping = false;
  late AnimationController _wingController;

  @override
  void initState() {
    super.initState();
    _wingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _wingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF080c10),
      appBar: AppBar(
        backgroundColor: Color(0xFF0e1419),
        title: Row(
          children: [
            Text('🦋 ', style: TextStyle(fontSize: 20)),
            Text(
              'Emo Care',
              style: TextStyle(
                color: Color(0xFF00d4aa),
                fontFamily: 'Space Mono',
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF00d4aa).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF00d4aa)),
            ),
            child: Text(
              'PROTECTED',
              style: TextStyle(
                color: Color(0xFF00d4aa),
                fontSize: 10,
                fontFamily: 'Space Mono',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Guardian status
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF7c5cfc).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF7c5cfc).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, color: Color(0xFF7c5cfc), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You are safe here. Your messages are sent to an AI service to reply. 🦋',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'Syne',
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, -10 * value),
                          child: Opacity(
                            opacity: 0.5 + (0.5 * value),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🦋', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text(
                            'Whenever you are ready, I am here.',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontFamily: 'Syne',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(15),
                    itemCount: messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return _buildTypingBubble();
                      }
                      return _buildMessageBubble(messages[index]);
                    },
                  ),
          ),
          
          // Input
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isUser = msg['isUser'] ?? false;
    bool isHealing = msg['isHealing'] ?? false;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser 
            ? Color(0xFF00d4aa).withOpacity(0.1)
            : isHealing
              ? Color(0xFF7c5cfc).withOpacity(0.15)
              : Color(0xFF141b22),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isUser 
              ? Color(0xFF00d4aa).withOpacity(0.3)
              : isHealing
                ? Color(0xFF7c5cfc).withOpacity(0.3)
                : Color(0xFF1e2a35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg['text'] ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Syne',
                height: 1.6,
              ),
            ),
            if (isHealing) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.favorite, color: Color(0xFFff6b6b), size: 12),
                  SizedBox(width: 6),
                  Text(
                    'Emo Care • Healing Mode',
                    style: TextStyle(
                      color: Color(0xFFff6b6b),
                      fontSize: 9,
                      fontFamily: 'Space Mono',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFF0e1419),
        border: Border(
          top: BorderSide(color: Color(0xFF1e2a35)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF141b22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFF1e2a35)),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Syne',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Type how you feel...',
                  hintStyle: TextStyle(
                    color: Colors.white30,
                    fontFamily: 'Syne',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Color(0xFF00d4aa),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.send, color: Color(0xFF080c10)),
            ),
          ),
        ],
      ),
    );
  }

  // ===== TYPING INDICATOR =====
  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: _wingController,
        builder: (context, child) {
          final t = _wingController.value; // 0 = wings closed, 1 = open
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF141b22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFF00d4aa).withOpacity(0.15 + 0.25 * t),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00d4aa).withOpacity(0.10 + 0.20 * t),
                  blurRadius: 8 + 12 * t,
                ),
              ],
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(0.35 + 0.65 * t, 0.9 + 0.1 * t, 1.0),
              child: Text('🦋', style: TextStyle(fontSize: 26)),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;
    
    controller.clear();
    
    // Add user message
    setState(() {
      messages.add({
        'text': text,
        'isUser': true,
        'isHealing': false,
      });
    });
    
    _scrollToBottom();
    
    // ===== TYPING INDICATOR ON =====
    setState(() {
      _isTyping = true;
    });
    _scrollToBottom();

    // Detect emotion
    String emotion = EmotionDetector.detect(text);
    
    // Get AI response
    String response;
    try {
      response = await EmoCare.getResponse(text, emotion);
    } finally {
      // ===== TYPING INDICATOR OFF =====
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
    
    // Add AI message
    setState(() {
      messages.add({
        'text': response,
        'isUser': false,
        'isHealing': emotion != 'neutral',
      });
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
