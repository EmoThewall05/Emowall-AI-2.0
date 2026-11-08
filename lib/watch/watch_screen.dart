/* ===== WATCH SCREEN ===== */
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:emowall/services/watch_api.dart';

class WatchScreen extends StatefulWidget {
  const WatchScreen({super.key});
  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  List<Map<String, dynamic>> _devices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await WatchApi.list();
      if (!mounted) return;
      setState(() {
        _devices = d;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _ago(dynamic iso) {
    final t = iso is String ? DateTime.tryParse(iso)?.toLocal() : null;
    if (t == null) return 'never';
    final m = DateTime.now().difference(t).inMinutes;
    if (m < 1) return 'just now';
    if (m < 60) return '$m min ago';
    if (m < 1440) return '${m ~/ 60} h ago';
    return '${m ~/ 1440} d ago';
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _add() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111519),
        title: Text("Child's name",
            style: GoogleFonts.syne(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          maxLength: 40,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'e.g. Anu'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Create code')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      final r = await WatchApi.createDevice(name);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF111519),
          title: Text('Pairing code',
              style: GoogleFonts.syne(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SelectableText('${r['pairCode']}',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                        color: const Color(0xFF00E676))),
              ),
              const SizedBox(height: 12),
              Text(
                  "Enter this code on the child's Emowall watch within 10 minutes.",
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 11, color: const Color(0xFF8892A4))),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done')),
          ],
        ),
      );
      _load();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _remove(Map<String, dynamic> d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111519),
        title: Text('Remove watch?',
            style: GoogleFonts.syne(color: Colors.white)),
        content: Text(
            "Remove ${d['childName']}'s watch? Its last saved location will be deleted.",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await WatchApi.delete('${d['id']}');
      _load();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _openMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _card(Map<String, dynamic> d) {
    final lat = (d['lat'] as num?)?.toDouble();
    final lng = (d['lng'] as num?)?.toDouble();
    final paired = d['paired'] == true;
    final batt = d['battery'];
    final small = GoogleFonts.jetBrainsMono(
        fontSize: 11, height: 1.6, color: const Color(0xFF8892A4));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111519),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: paired ? const Color(0xFF00E676) : const Color(0xFF3B82F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⌚ ${d['childName'] ?? ''}',
              style: GoogleFonts.syne(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(paired ? 'Paired' : 'Waiting for pairing', style: small),
          Text('Last location: ${_ago(d['locAt'])}', style: small),
          Text('Battery: ${batt != null ? '$batt%' : 'unknown'}',
              style: small),
          Row(
            children: [
              if (lat != null && lng != null)
                TextButton.icon(
                  onPressed: () => _openMap(lat, lng),
                  icon: const Icon(Icons.location_on, size: 18),
                  label: const Text('Open location'),
                ),
              const Spacer(),
              IconButton(
                onPressed: () => _remove(d),
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111519),
        foregroundColor: Colors.white,
        title: Text("Child's Watch",
            style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: const Color(0xFFEF4444),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111519),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emowall watch app: coming soon',
                            style: GoogleFonts.syne(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(
                            'You can add a watch and get a pairing code now. Alerts and live location start only when the Emowall watch app is installed and paired. Emowall is not a medical device.',
                            style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                height: 1.5,
                                color: const Color(0xFF8892A4))),
                      ],
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!,
                          style: const TextStyle(color: Color(0xFFEF4444))),
                    ),
                  if (_devices.isEmpty && _error == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(
                          "No watch added yet.\nTap + to add your child's watch.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ..._devices.map(_card),
                ],
              ),
            ),
    );
  }
}
/* ===== END WATCH SCREEN ===== */
