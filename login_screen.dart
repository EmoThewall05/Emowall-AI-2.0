import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emowall/widgets/butterfly_logo.dart'; // നിന്റെ ശലഭത്തിന്റെ ലോഗോ വിഡ്ജറ്റ്
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // ശലഭത്തിന്റെ തിളക്കത്തിന് വേണ്ടിയുള്ള ആനിമേഷൻ
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Auth Actions ───────────────────────────────────────────
  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      if (_isLogin) {
        await _authService.signInWithEmail(
          email: _emailController.text, password: _passwordController.text,
        );
      } else {
        await _authService.signUpWithEmail(
          email: _emailController.text, password: _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // ⭐ നിന്റെ സിഗ്നേച്ചർ ബട്ടർഫ്ലൈ ആനിമേഷൻ
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5500).withOpacity(_glowAnimation.value),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const ButterflyLogo(size: 85),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('Emowall AI', style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFFFF5500))),
              Text('YOUR SILENT GUARDIAN', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF8892A4), letterSpacing: 2)),
              const SizedBox(height: 40),
              
              _buildForm(),
              
              if (_errorMessage != null) _buildError(),
              const SizedBox(height: 32),
              
              _buildSubmitButton(),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildGoogleButton(),
              const SizedBox(height: 12),
              
              // 🛡️ Wallet Connection for 540+ Wallets
              _buildWalletButton(),
              
              const SizedBox(height: 32),
              _buildToggle(),
              const SizedBox(height: 40),
              
              // DXB to Kerala Connection Meta
              Text(
                "BUILT ON MOBILE • DXB 🇦🇪 IND 🇮🇳",
                style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.white.withOpacity(0.2), letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Guardian Email',
            icon: Icons.mail_outline_rounded,
            hint: 'email@emowall.ai',
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _passwordController,
            label: 'Secure Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            hint: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF8892A4), size: 18),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, required String hint, bool obscureText = false, Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(color: const Color(0xFF8892A4), fontSize: 11)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF333344)),
            prefixIcon: Icon(icon, color: const Color(0xFFFF5500), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF111519),
            contentPadding: const EdgeInsets.all(18),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF5500))),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitEmailAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5500),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text(_isLogin ? 'ENTER FORTRESS' : 'CREATE ACCOUNT', style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize:
