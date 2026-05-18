import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';

class VerificationChainService {
  static final VerificationChainService _instance = VerificationChainService._internal();
  factory VerificationChainService() => _instance;
  VerificationChainService._internal();

  Timer? _chainTimer;
  int _currentStep = 0;
  bool _isChainActive = false;
  bool _verified = false;
  String _alertReason = '';

  // Contacts — app-ൽ user set ചെയ്യും
  final List<ChainContact> contacts = [
    ChainContact(name: 'Parent/Guardian', phone: '+91XXXXXXXXXX', role: ContactRole.parent, windowSeconds: 60),
    ChainContact(name: 'Relative', phone: '+91XXXXXXXXXX', role: ContactRole.relative, windowSeconds: 30),
    ChainContact(name: 'School Principal', phone: '+91XXXXXXXXXX', role: ContactRole.principal, windowSeconds: 30),
  ];

  // Government contacts
  static const String _keralaPolice = '919497900000';
  static const String _cyberCell = '911930';
  static const String _childHelpline = '911098';
  static const String _womenHelpline = '911091';

  Function(ChainStatus)? _onStatusUpdate;

  Future<void> startChain({
    required String reason,
    required Function(ChainStatus) onStatusUpdate,
  }) async {
    if (_isChainActive) return;
    _isChainActive = true;
    _verified = false;
    _currentStep = 0;
    _alertReason = reason;
    _onStatusUpdate = onStatusUpdate;

    debugPrint('🚨 Verification chain started: $reason');
    await _processStep();
  }

  Future<void> _processStep() async {
    if (_verified || !_isChainActive) return;

    // All contacts exhausted → Auto SOS
    if (_currentStep >= contacts.length) {
      await _triggerAutoSOS();
      return;
    }

    final contact = contacts[_currentStep];

    // Notify current contact
    await _notifyContact(contact);

    _onStatusUpdate?.call(ChainStatus(
      step: _currentStep + 1,
      totalSteps: contacts.length,
      currentContact: contact.name,
      role: contact.role,
      waitingSeconds: contact.windowSeconds,
      message: '⏳ Waiting for ${contact.name} to respond...',
    ));

    // Wait for response window
    _chainTimer = Timer(Duration(seconds: contact.windowSeconds), () async {
      if (!_verified && _isChainActive) {
        _currentStep++;
        await _processStep();
      }
    });
  }

  Future<void> _notifyContact(ChainContact contact) async {
    final phone = contact.phone.replaceAll('+', '').replaceAll(' ', '');
    
    final msg = Uri.encodeComponent(
      '🚨 EMOWALL EMERGENCY ALERT\n'
      '━━━━━━━━━━━━━━━━━━━\n'
      'Child needs help: $_alertReason\n'
      '📍 Live Location: https://maps.google.com/?q=mylocation\n'
      '⏰ ${DateTime.now().toString().substring(0, 19)}\n'
      '━━━━━━━━━━━━━━━━━━━\n'
      '✅ Reply "SAFE" if child is okay\n'
      '🚨 Reply "HELP" to escalate immediately\n'
      'Auto SOS in ${contact.windowSeconds} seconds if no response.\n'
      '🛡️ Emowall AI 2.0',
    );

    // WhatsApp
    final waUrl = 'https://wa.me/$phone?text=$msg';
    if (await canLaunchUrl(Uri.parse(waUrl))) {
      await launchUrl(Uri.parse(waUrl), mode: LaunchMode.externalApplication);
    }

    // Direct call
    await Future.delayed(const Duration(seconds: 3));
    final callUrl = 'tel:${contact.phone}';
    if (await canLaunchUrl(Uri.parse(callUrl))) {
      await launchUrl(Uri.parse(callUrl));
    }
  }

  // Parent/relative confirms child is safe
  void confirmSafe() {
    _verified = true;
    _chainTimer?.cancel();
    _isChainActive = false;
    _onStatusUpdate?.call(ChainStatus(
      step: _currentStep,
      totalSteps: contacts.length,
      currentContact: '',
      role: ContactRole.parent,
      waitingSeconds: 0,
      message: '✅ Confirmed safe. Alert cancelled.',
    ));
  }

  Future<void> _triggerAutoSOS() async {
    _onStatusUpdate?.call(ChainStatus(
      step: contacts.length,
      totalSteps: contacts.length,
      currentContact: 'Police + Authorities',
      role: ContactRole.authority,
      waitingSeconds: 0,
      message: '🚨 AUTO SOS TRIGGERED — Alerting authorities!',
    ));

    // Start live GPS tracking
    await LocationService().startLiveTracking(
      contacts: contacts.map((c) => {'name': c.name, 'phone': c.phone}).toList(),
      reason: _alertReason,
      silent: true,
    );

    final sosMsg = Uri.encodeComponent(
      '🚨🚨 EMERGENCY — EMOWALL AUTO SOS 🚨🚨\n'
      '━━━━━━━━━━━━━━━━━━━\n'
      'CHILD IN DANGER: $_alertReason\n'
      '📍 Live Location: https://maps.google.com/?q=mylocation\n'
      '⏰ ${DateTime.now().toString().substring(0, 19)}\n'
      '━━━━━━━━━━━━━━━━━━━\n'
      'No response from family contacts.\n'
      'IMMEDIATE ACTION REQUIRED.\n'
      '🛡️ Emowall AI 2.0 — Auto Alert System',
    );

    // Alert all authorities simultaneously
    final authorities = [
      _keralaPolice,
      _cyberCell,
      _childHelpline,
      _womenHelpline,
    ];

    for (final number in authorities) {
      final url = 'https://wa.me/$number?text=$sosMsg';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Call police directly
    final policeCall = 'tel:+$_keralaPolice';
    if (await canLaunchUrl(Uri.parse(policeCall))) {
      await launchUrl(Uri.parse(policeCall));
    }

    _isChainActive = false;
  }

  void stopChain() {
    _chainTimer?.cancel();
    _isChainActive = false;
    _verified = false;
    _currentStep = 0;
  }

  bool get isActive => _isChainActive;
}

// Models
enum ContactRole { parent, relative, principal, authority }

class ChainContact {
  final String name;
  final String phone;
  final ContactRole role;
  final int windowSeconds;

  ChainContact({
    required this.name,
    required this.phone,
    required this.role,
    required this.windowSeconds,
  });
}

class ChainStatus {
  final int step;
  final int totalSteps;
  final String currentContact;
  final ContactRole role;
  final int waitingSeconds;
  final String message;

  ChainStatus({
    required this.step,
    required this.totalSteps,
    required this.currentContact,
    required this.role,
    required this.waitingSeconds,
    required this.message,
  });
}
