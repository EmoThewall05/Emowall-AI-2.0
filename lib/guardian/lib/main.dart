// Add to your bottom nav or menu
ListTile(
  leading: Text('🦋', style: TextStyle(fontSize: 24)),
  title: Text(
    'Butterfly Guardian',
    style: TextStyle(color: Color(0xFF00d4aa)),
  ),
  subtitle: Text(
    'Talk safely, heal silently',
    style: TextStyle(color: Colors.white54, fontSize: 12),
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GuardianChatScreen()),
    );
  },
)
