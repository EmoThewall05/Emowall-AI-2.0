import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});
  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _loadContacts() async {
    if (_uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await _supabase
          .from('emergency_contacts')
          .select()
          .eq('firebase_uid', _uid as String)
          .order('created_at');
      setState(() {
        _contacts = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Load failed: $e')));
      }
    }
  }

  Future<void> _addOrEditContact({Map<String, dynamic>? existing}) async {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final relationCtrl = TextEditingController(text: existing?['relation'] ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111519),
        title: Text(existing == null ? 'Add Contact' : 'Edit Contact',
            style: GoogleFonts.syne(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Name (e.g. Amma, Achan)'),
            ),
            TextField(
              controller: relationCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Relation (e.g. Parent, Relative, Principal)'),
            ),
            TextField(
              controller: phoneCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Phone (with country code, e.g. +9715XXXXXXXX)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );

    if (result != true || _uid == null) return;
    if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;

    try {
      if (existing == null) {
        await _supabase.from('emergency_contacts').insert({
          'firebase_uid': _uid,
          'name': nameCtrl.text.trim(),
          'relation': relationCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
        });
      } else {
        await _supabase.from('emergency_contacts').update({
          'name': nameCtrl.text.trim(),
          'relation': relationCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
        }).eq('id', existing['id']);
      }
      await _loadContacts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    }
  }

  Future<void> _deleteContact(String id) async {
    try {
      await _supabase.from('emergency_contacts').delete().eq('id', id);
      await _loadContacts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0F14),
        title: Text('ðŸš¨ Emergency Contacts',
            style: GoogleFonts.syne(fontWeight: FontWeight.w800, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF4444),
        onPressed: () => _addOrEditContact(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _uid == null
              ? const Center(
                  child: Text('Please sign in to manage emergency contacts',
                      style: TextStyle(color: Colors.white70)))
              : _contacts.isEmpty
                  ? const Center(
                      child: Text(
                          'No emergency contacts yet.\nTap + to add parent, relative or school principal.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _contacts.length,
                      itemBuilder: (ctx, i) {
                        final c = _contacts[i];
                        return Card(
                          color: const Color(0xFF111519),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(c['name'] ?? '',
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text('${c['relation'] ?? ''} â€¢ ${c['phone'] ?? ''}',
                                style: const TextStyle(color: Colors.white70)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white70),
                                  onPressed: () => _addOrEditContact(existing: c),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteContact(c['id'] as String),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
