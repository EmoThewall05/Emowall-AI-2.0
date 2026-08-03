import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth_service.dart';
import '../login_page.dart';

// ============================================================
// COLORS
// ============================================================
class EmowallColors {
  static const Color background = Color(0xFF0A0A0A);
  static const Color card = Color(0xFF141414);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color orange = Color(0xFFFF6B1A);
  static const Color orangeDim = Color(0xFFFF6B1A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color danger = Color(0xFFE53935);
  static const Color green = Color(0xFF2ECC71);
}

// ============================================================
// EMERGENCY CONTACT MODEL
// ============================================================
class EmergencyContact {
  String name;
  String phone;
  String relation;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });
}

// ============================================================
// PROFILE PAGE
// ============================================================
class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final DateTime memberSince;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.memberSince,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<EmergencyContact> _contacts = [];
  File? _profileImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfileImage() async {
    if (_profileImage == null) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _showSnack('You must be signed in to save a photo.', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final bytes = await _profileImage!.readAsBytes();
      final path = '$userId/avatar.jpg';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      if (mounted) {
        _showSnack('Profile photo saved.');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to save photo: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? EmowallColors.danger : EmowallColors.green,
      ),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EmowallColors.card,
        title: const Text(
          'Sign Out',
          style: TextStyle(color: EmowallColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: EmowallColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: EmowallColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: EmowallColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService().signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  void _showAddContactSheet({EmergencyContact? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final relationCtrl = TextEditingController(text: existing?.relation ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: EmowallColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'Add Emergency Contact' : 'Edit Contact',
                style: const TextStyle(
                  color: EmowallColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(nameCtrl, 'Name'),
              const SizedBox(height: 12),
              _buildTextField(phoneCtrl, 'Phone number', keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(relationCtrl, 'Relation (e.g. Mother, Friend)'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EmowallColors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty ||
                        phoneCtrl.text.trim().isEmpty) {
                      return;
                    }
                    setState(() {
                      final contact = EmergencyContact(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        relation: relationCtrl.text.trim().isEmpty
                            ? 'Contact'
                            : relationCtrl.text.trim(),
                      );
                      if (index != null) {
                        _contacts[index] = contact;
                      } else {
                        _contacts.add(contact);
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    existing == null ? 'Add Contact' : 'Save Changes',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: EmowallColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: EmowallColors.textSecondary),
        filled: true,
        fillColor: EmowallColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: EmowallColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: EmowallColors.orange),
        ),
      ),
    );
  }

  void _deleteContact(int index) {
    setState(() => _contacts.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmowallColors.background,
      appBar: AppBar(
        backgroundColor: EmowallColors.background,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: EmowallColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: EmowallColors.orange),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserHeader(),
          if (_profileImage != null) ...[
            const SizedBox(height: 12),
            _buildSaveImageButton(),
          ],
          const SizedBox(height: 24),
          _buildSectionTitle('Emergency Contacts'),
          const SizedBox(height: 10),
          ..._contacts.asMap().entries.map(
                (e) => _buildContactCard(e.value, e.key),
              ),
          _buildAddContactButton(),
          const SizedBox(height: 24),
          _buildSectionTitle('Support'),
          const SizedBox(height: 10),
          _buildSupportCard(context),
          const SizedBox(height: 24),
          _buildSignOutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSaveImageButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: EmowallColors.orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isUploading ? null : _saveProfileImage,
        child: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Text(
                'Save Profile Photo',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return InkWell(
      onTap: _signOut,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EmowallColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: EmowallColors.danger.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: EmowallColors.danger.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: EmowallColors.danger),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: EmowallColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: EmowallColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EmowallColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmowallColors.cardBorder),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _profileImage == null
                      ? const LinearGradient(
                          colors: [EmowallColors.orange, Color(0xFFFF9455)],
                        )
                      : null,
                  image: _profileImage != null
                      ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: EmowallColors.orange.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _profileImage == null
                    ? Center(
                        child: Text(
                          widget.userName.isNotEmpty
                              ? widget.userName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: EmowallColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: EmowallColors.background,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: EmowallColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userEmail,
                  style: const TextStyle(
                    color: EmowallColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: EmowallColors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Member since ${_formatDate(widget.memberSince)}',
                    style: const TextStyle(
                      color: EmowallColors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: EmowallColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EmowallColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EmowallColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: EmowallColors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: EmowallColors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: EmowallColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${contact.relation} • ${contact.phone}',
                  style: const TextStyle(
                    color: EmowallColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: EmowallColors.textSecondary, size: 18),
            onPressed: () => _showAddContactSheet(existing: contact, index: index),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: EmowallColors.danger, size: 18),
            onPressed: () => _deleteContact(index),
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactButton() {
    return InkWell(
      onTap: () => _showAddContactSheet(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: EmowallColors.orange, style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: EmowallColors.orange, size: 18),
            SizedBox(width: 6),
            Text(
              'Add Emergency Contact',
              style: TextStyle(
                color: EmowallColors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerSupportChatPage()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EmowallColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: EmowallColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: EmowallColors.orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent, color: EmowallColors.orange),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Support',
                    style: TextStyle(
                      color: EmowallColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Chat with our AI support about the app',
                    style: TextStyle(
                      color: EmowallColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: EmowallColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER SUPPORT CHAT PAGE
// ============================================================
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
}

class CustomerSupportChatPage extends StatefulWidget {
  const CustomerSupportChatPage({super.key});

  @override
  State<CustomerSupportChatPage> createState() =>
      _CustomerSupportChatPageState();
}

class _CustomerSupportChatPageState extends State<CustomerSupportChatPage> {
  static const String _workerUrl =
      'https://emowall-customer-support.meradivin.workers.dev';

  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      "Hi! I'm the Emowall Support Assistant. Ask me anything about "
      "app features, setup, or troubleshooting. 🧡",
      false,
    ),
  ];
  bool _isTyping = false;

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text, true));
      _isTyping = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    try {
      final response = await http
          .post(
            Uri.parse(_workerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': text}),
          )
          .timeout(const Duration(seconds: 20));

      String reply;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        reply = data['reply'] ?? "Sorry, I couldn't process that. Try again.";
      } else {
        reply = "Support is temporarily busy. Please try again shortly.";
      }

      setState(() {
        _messages.add(ChatMessage(reply, false));
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          "Network issue — please check your connection and try again.",
          false,
        ));
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmowallColors.background,
      appBar: AppBar(
        backgroundColor: EmowallColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: EmowallColors.orange),
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: EmowallColors.orange),
            SizedBox(width: 8),
            Text(
              'Customer Support',
              style: TextStyle(
                color: EmowallColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingBubble();
                }
                final msg = _messages[index];
                return _buildBubble(msg);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? EmowallColors.orange : EmowallColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(msg.isUser ? 14 : 2),
            bottomRight: Radius.circular(msg.isUser ? 2 : 14),
          ),
          border: msg.isUser
              ? null
              : Border.all(color: EmowallColors.cardBorder),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.black : EmowallColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: EmowallColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: EmowallColors.cardBorder),
        ),
        child: const SizedBox(
          width: 24,
          height: 12,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: EmowallColors.orange,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: EmowallColors.card,
        border: Border(top: BorderSide(color: EmowallColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                style: const TextStyle(color: EmowallColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ask about the app...',
                  hintStyle: const TextStyle(color: EmowallColors.textSecondary),
                  filled: true,
                  fillColor: EmowallColors.background,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: EmowallColors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.black, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
