import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/butterfly_logo.dart';

// ==================== LOGIN SCREEN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _selectedTab = 0; // 0=Phone, 1=Email

  // Phone OTP
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _phoneLoading = false;

  // Email
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _emailLoading = false;
  bool _obscurePassword = true;
  bool _isRegister = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    if (_phoneController.text.length < 10) {
      _showSnack('Enter valid phone number', const Color(0xFFEF4444));
      return;
    }
    setState(() => _phoneLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _phoneLoading = false; _otpSent = true; });
    _showSnack('OTP sent to +91 ${_phoneController.text}', const Color(0xFF00E676));
  }

  void _verifyOTP() async {
    if (_otpController.text.length < 4) {
      _showSnack('Enter valid OTP', const Color(0xFFEF4444));
      return;
    }
    setState(() => _phoneLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _phoneLoading = false);
    _navigateHome();
  }

  void _emailLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack('Enter email and password', const Color(0xFFEF4444));
      return;
    }
    if (_isRegister && _nameController.text.isEmpty) {
      _showSnack('Enter your name', const Color(0xFFEF4444));
      return;
    }
    setState(() => _emailLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _emailLoading = false);
    _navigateHome();
  }

  void _googleSignIn() async {
    _showSnack('Google Sign In coming soon...', const Color(0xFF4285F4));
  }

  void _navigateHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: GoogleFonts.jetBrainsMono(fontSize: 12)), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // â”€â”€ Header â”€â”€
                Center(
                  child: Column(
                    children: [
                      const ButterflyLogo(size: 64),
                      const SizedBox(height: 16),
                      Text('Emowall', style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFFFF5500))),
                      Text('AI 2.0', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF00E676), letterSpacing: 2)),
                      const SizedBox(height: 6),
                      Text('Your Family\'s Silent Guardian', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF8892A4))),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // â”€â”€ Tab Switcher â”€â”€
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111519),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E2530)),
                  ),
                  child: Row(
                    children: [
                      _tabBtn('ðŸ“± Phone', 0),
                      _tabBtn('âœ‰ï¸ Email', 1),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // â”€â”€ Phone Tab â”€â”€
                if (_selectedTab == 0) ...[
                  if (!_otpSent) ...[
                    Text('Phone Number', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8892A4))),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111519),
                          border: Border.all(color: const Color(0xFF1E2530)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('+91', style: GoogleFonts.jetBrainsMono(color: const Color(0xFFFF5500), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _inputField(
                          controller: _phoneController,
                          hint: '98478 42172',
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _primaryButton(
                      label: _phoneLoading ? 'Sending OTP...' : 'Send OTP',
                      icon: Icons.sms,
                      color: const Color(0xFFFF5500),
                      onTap: _phoneLoading ? null : _sendOTP,
                      loading: _phoneLoading,
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withOpacity(0.08),
                        border: Border.all(color: const Color(0xFF00E676).withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 18),
                        const SizedBox(width: 8),
                        Text('OTP sent to +91 ${_phoneController.text}', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF00E676))),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Text('Enter OTP', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8892A4))),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: _otpController,
                      hint: 'â€¢ â€¢ â€¢ â€¢ â€¢ â€¢',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => setState(() => _otpSent = false),
                        child: Text('Change number?', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFFFF5500))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _primaryButton(
                      label: _phoneLoading ? 'Verifying...' : 'Verify & Login',
                      icon: Icons.verified_user,
                      color: const Color(0xFF00E676),
                      onTap: _phoneLoading ? null : _verifyOTP,
                      loading: _phoneLoading,
                    ),
                  ],
                ],

                // â”€â”€ Email Tab â”€â”€
                if (_selectedTab == 1) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isRegister = false),
                        child: Text('Login', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: !_isRegister ? Colors.white : const Color(0xFF8892A4))),
                      ),
                      const SizedBox(width: 8),
                      Text('/', style: GoogleFonts.syne(color: const Color(0xFF1E2530))),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isRegister = true),
                        child: Text('Register', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: _isRegister ? Colors.white : const Color(0xFF8892A4))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isRegister) ...[
                    Text('Full Name', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8892A4))),
                    const SizedBox(height: 8),
                    _inputField(controller: _nameController, hint: 'Dwin K.K.', icon: Icons.person_outline),
                    const SizedBox(height: 16),
                  ],
                  Text('Email', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8892A4))),
                  const SizedBox(height: 8),
                  _inputField(controller: _emailController, hint: 'meradivin@gmail.com', keyboardType: TextInputType.emailAddress, icon: Icons.email_outlined),
                  const SizedBox(height: 16),
                  Text('Password', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8892A4))),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _passwordController,
                    hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢',
                    obscureText: _obscurePassword,
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF8892A4), size: 18),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _primaryButton(
                    label: _emailLoading ? 'Please wait...' : (_isRegister ? 'Create Account' : 'Login'),
                    icon: _isRegister ? Icons.person_add : Icons.login,
                    color: const Color(0xFFFF5500),
                    onTap: _emailLoading ? null : _emailLogin,
                    loading: _emailLoading,
                  ),
                ],

                const SizedBox(height: 24),

                // â”€â”€ Divider â”€â”€
                Row(children: [
                  Expanded(child: Divider(color: const Color(0xFF1E2530))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF8892A4))),
                  ),
                  Expanded(child: Divider(color: const Color(0xFF1E2530))),
                ]),
                const SizedBox(height: 24),

                // â”€â”€ Google Sign In â”€â”€
                GestureDetector(
                  onTap: _googleSignIn,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111519),
                      border: Border.all(color: const Color(0xFF1E2530)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('G', style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF4285F4))),
                        const SizedBox(width: 12),
                        Text('Continue with Google', style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // â”€â”€ Footer â”€â”€
                Center(
                  child: Text(
                    'By continuing you agree to Emowall\'s\nPrivacy Policy & Terms of Service',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF5500) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF8892A4)), textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? icon,
    Widget? suffixIcon,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    double fontSize = 15,
    double letterSpacing = 0,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      textAlign: textAlign,
      style: GoogleFonts.jetBrainsMono(fontSize: fontSize, color: Colors.white, letterSpacing: letterSpacing),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.jetBrainsMono(fontSize: fontSize, color: const Color(0xFF3A4555), letterSpacing: letterSpacing),
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF8892A4), size: 18) : null,
        suffixIcon: suffixIcon,
        counterText: '',
        filled: true,
        fillColor: const Color(0xFF111519),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E2530))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E2530))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF5500), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _primaryButton({required String label, required IconData icon, required Color color, VoidCallback? onTap, bool loading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onTap == null ? color.withOpacity(0.5) : color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: loading
            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(label, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
      ),
    );
  }
}
