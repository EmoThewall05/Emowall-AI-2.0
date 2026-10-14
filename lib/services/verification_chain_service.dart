import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'contacts_api.dart';
import 'location_service.dart';
import 'sos_api.dart';

/// Escalation: parent -> relative -> principal -> all contacts.
/// Every step is a server-sent SMS to a contact the user added.
/// Nothing opens WhatsApp or the dialer, and no authority is contacted
/// automatically.
class VerificationChainService {
  static final VerificationChainService _instance =
      VerificationChainService._internal();
  factory VerificationChainService() => _instance;
  VerificationChainService._internal();

  bool _isChainActive = false;
  bool _verified = false;
  int _runId = 0;
  int _currentStep = 0;
  String _alertReason = '';
  String? _eventId;
  String _childName = 'A child';
  Function(ChainStatus)? _onStatusUpdate;

  final List<ChainContact> contacts = [];

  ContactRole _roleFor(String relation) {
    final r = relation.toLowerCase();
    if (r.contains('principal') || r.contains('teacher') || r.contains('school')) {
      return ContactRole.principal;
    }
    if (r.contains('parent') || r.contains('mother') || r.contains('father') ||
        r.contains('mom') || r.contains('dad') || r.contains('amma') ||
        r.contains('achan') || r.contains('guardian')) {
      return ContactRole.parent;
    }
    return ContactRole.relative;
  }

  void _emit(int step, String name, ContactRole role, int wait, String message) {
    _onStatusUpdate?.call(ChainStatus(
      step: step,
      totalSteps: contacts.length,
      currentContact: name,
      role: role,
      waitingSeconds: wait,
      message: message,
    ));
  }

  Future<T?> _try<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      debugPrint('SOS call failed: $e');
      return null;
    }
  }

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
    final runId = ++_runId;

    final display = FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
    _childName = display.isEmpty ? 'A child' : display.split(' ').first;

    try {
      final list = await ContactsApi.list();
      final found = <ChainContact>[];
      for (final c in list) {
        final phone = (c['phone'] ?? '').toString().trim();
        if (phone.isEmpty) continue;
        found.add(ChainContact(
          id: (c['id'] ?? '').toString(),
          name: (c['name'] ?? '').toString(),
          phone: phone,
          role: _roleFor((c['relation'] ?? '').toString()),
          windowSeconds: 30,
        ));
      }
      found.sort((a, b) => a.role.index.compareTo(b.role.index));
      contacts
        ..clear()
        ..addAll([
          for (var i = 0; i < found.length; i++)
            ChainContact(
              id: found[i].id,
              name: found[i].name,
              phone: found[i].phone,
              role: found[i].role,
              windowSeconds: i == 0 ? 60 : 30,
            ),
        ]);

      if (contacts.isEmpty) {
        _isChainActive = false;
        _emit(0, '', ContactRole.parent, 0,
            '⚠️ No emergency contacts. Add contacts in Profile so alerts can be sent.');
        return;
      }

      final pos = await LocationService().currentPosition();
      _eventId = await SosApi.start(
        reason: reason,
        childName: _childName,
        lat: pos?.latitude,
        lng: pos?.longitude,
      );
    } catch (e) {
      debugPrint('Chain start failed: $e');
      _isChainActive = false;
      _emit(0, '', ContactRole.parent, 0,
          '⚠️ Could not reach the alert server. Check the internet connection.');
      return;
    }

    unawaited(LocationService()
        .startLiveTracking(contacts: const [], reason: reason, silent: true));
    unawaited(_run(runId));
  }

  Future<void> _run(int runId) async {
    bool active() => _isChainActive && !_verified && _runId == runId;

    for (var i = 0; i < contacts.length && active(); i++) {
      final c = contacts[i];
      _currentStep = i;
      final pos = await LocationService().currentPosition();
      final res = await _try(() => SosApi.notify(
            eventId: _eventId!,
            contactId: c.id,
            childName: _childName,
            lat: pos?.latitude,
            lng: pos?.longitude,
          ));
      if (!active()) return;
      if (res != null && res['status'] == 'safe') {
        _markSafe();
        return;
      }
      final sent = res == null ? 0 : (res['sent'] ?? 0) as int;
      _emit(
        i + 1,
        c.name,
        c.role,
        c.windowSeconds,
        sent > 0
            ? '⏳ Alert sent to ${c.name}. Waiting ${c.windowSeconds}s for confirmation...'
            : '⚠️ SMS to ${c.name} could not be sent. Escalating...',
      );

      var waited = 0;
      while (waited < c.windowSeconds && active()) {
        await Future.delayed(const Duration(seconds: 5));
        waited += 5;
        if (!active()) return;
        final st = await _try(() => SosApi.status(_eventId!));
        if (st == 'safe') {
          _markSafe();
          return;
        }
      }
    }
    if (active()) await _autoSOS();
  }

  Future<void> _autoSOS() async {
    _emit(contacts.length, 'All contacts', ContactRole.authority, 0,
        '🚨 No confirmation. Alerting ALL contacts...');
    final pos = await LocationService().currentPosition();
    final res = await _try(() => SosApi.notify(
          eventId: _eventId!,
          all: true,
          childName: _childName,
          lat: pos?.latitude,
          lng: pos?.longitude,
        ));
    final sent = res == null ? 0 : (res['sent'] ?? 0) as int;
    _emit(
      contacts.length,
      'All contacts',
      ContactRole.authority,
      0,
      sent > 0
          ? '🚨 All contacts alerted. If the child is in danger, call 112 now.'
          : '⚠️ Alerts could not be sent. Call 112 now.',
    );
    _isChainActive = false;
  }

  void _markSafe() {
    _verified = true;
    _isChainActive = false;
    _runId++;
    LocationService().stopTracking();
    SosApi.currentEventId = null;
    _emit(_currentStep, '', ContactRole.parent, 0,
        '✅ Confirmed safe. Alert cancelled.');
  }

  /// The child (or a parent in the app) confirms safety.
  void confirmSafe() {
    final id = _eventId;
    _markSafe();
    if (id != null) unawaited(_try(() => SosApi.markSafe(id)));
  }

  void stopChain() {
    _runId++;
    _isChainActive = false;
    _verified = false;
    _currentStep = 0;
    final id = _eventId;
    _eventId = null;
    SosApi.currentEventId = null;
    if (id != null) unawaited(_try(() => SosApi.close(id)));
  }

  bool get isActive => _isChainActive;
}

// Models
enum ContactRole { parent, relative, principal, authority }

class ChainContact {
  final String id;
  final String name;
  final String phone;
  final ContactRole role;
  final int windowSeconds;

  ChainContact({
    this.id = '',
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
