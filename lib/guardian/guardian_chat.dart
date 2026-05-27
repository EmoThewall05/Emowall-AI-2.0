import 'package:flutter/material.dart';
import 'guardian_ai.dart';
import 'emotion_detector.dart';

class GuardianChatScreen extends StatefulWidget {
  @override
  _GuardianChatScreenState createState() => _GuardianChatScreenState();
}

class _GuardianChatScreenState extends State<GuardianChatScreen> {
  List<Map<String, dynamic>> messages = [];
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

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
              'Butterfly Guardian',
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
                    'You are safe here. Whatever you share stays between us. 🦋',
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
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
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
          borderRadius: BorderRadius.circular(16),
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
                    'Butterfly Guardian • Healing Mode',
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
    
    // Detect emotion
    String emotion = EmotionDetector.detect(text);
    
    // Get AI response
    String response = await ButterflyGuardian.getResponse(text, emotion);
    
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
