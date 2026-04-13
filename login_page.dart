// ... (നിന്റെ നിലവിലുള്ള ഇംപോർട്ടുകൾ നിലനിർത്തുക)
import 'package:flutter/material.dart';
// വാലറ്റ് കണക്ടിവിറ്റിക്ക് വേണ്ടിയുള്ള പാക്കേജ് ഇംപോർട്ട് ചെയ്യുക (reown/walletconnect)

// ... (നിന്റെ സ്റ്റേറ്റ്ഫുൾ വിഡ്ജറ്റ് ക്ലാസ്സ് ഇവിടെ തുടങ്ങുന്നു)

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ... (StatusBar സെറ്റിംഗ്സ്)

    return Scaffold(
      backgroundColor: _bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Stack( // സ്റ്റാക്ക് ഉപയോഗിക്കുന്നത് ബാക്ക്ഗ്രൗണ്ടിൽ ബട്ടർഫ്ലൈ ആനിമേഷൻ വരാൻ സഹായിക്കും
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildForm(),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) _buildError(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 20),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildGoogleButton(),
                    const SizedBox(height: 12), // ഗൂഗിളിന് താഴെ വാലറ്റ് സെക്ഷൻ
                    _buildWalletButton(), 
                    const SizedBox(height: 32),
                    _buildToggle(),
                    const SizedBox(height: 40),
                    _buildSignature(), // നിന്റെ സിഗ്നേച്ചർ
                  ],
                ),
              ),
              _buildButterflyChatFAB(), // AI ചാറ്റ് ബട്ടൺ
            ],
          ),
        ),
      ),
    );
  }

  // ── പുതിയ വാലറ്റ് ബട്ടൺ ──────────────────────────────────────────────────────
  Widget _buildWalletButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () {
          // ഇവിടുത്തെ ലോജിക്കിൽ നിന്റെ Alchemy/Reown വാലറ്റ് കണക്ട് ചെയ്യാം
          print("Connecting to 540+ Wallets...");
        },
        icon: const Icon(Icons.account_balance_wallet_outlined, color: _accentSoft, size: 20),
        label: const Text(
          'Connect Wallet (540+)',
          style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: _surface,
        ),
      ),
    );
  }

  // ── Butterfly Chat FAB ────────────────────────────────────────────────────
  Widget _buildButterflyChatFAB() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: () => print("Butterfly AI Chat Start"),
        backgroundColor: _accent,
        elevation: 10,
        child: const Icon(Icons.butterfly_interactive, color: Colors.white, size: 30),
      ),
    );
  }

  // ── Signature (UX by. / ) ────────────────────────────────────────────────
  Widget _buildSignature() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'UX by. / Signature', // ഇവിടെ നിന്റെ ആ സിഗ്നേച്ചർ നൽകാം
          style: TextStyle(color: _textSecondary, fontSize: 11, letterSpacing: 1.5),
        ),
      ),
    );
  }
