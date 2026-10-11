import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'about_screen.dart';
import 'budget_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const blue = Color(0xFF1565C0);
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    DatabaseHelper.instance.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await DatabaseHelper.instance.getAllSettings();
      if (!mounted) return;
      setState(() {
        _name = s['user_name'] ?? '';
        _email = s['user_email'] ?? '';
      });
    } catch (_) {}
  }

  String get _initial {
    final parts =
    _name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    return parts.isEmpty ? '' : parts.last[0].toUpperCase();
  }

  void _go(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Widget _item(IconData icon, String label, Widget page) {
    return ListTile(
      leading: Icon(icon, color: blue),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _go(page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _go(const ProfileInfoScreen()),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE3F2FD),
                    child: _initial.isEmpty
                        ? const Icon(Icons.person, size: 32, color: blue)
                        : Text(_initial,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: blue)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name.isEmpty ? 'Người dùng' : _name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(_email.isEmpty ? 'Chưa cập nhật email' : _email,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _item(Icons.person_outline, 'Thông tin cá nhân',
              const ProfileInfoScreen()),
          _item(Icons.savings_outlined, 'Cài đặt ngân sách',
              const BudgetScreen()),
          _item(Icons.notifications_none, 'Thông báo',
              const NotificationSettingsScreen()),
          _item(Icons.info_outline, 'Giới thiệu ứng dụng', const AboutScreen()),
        ],
      ),
    );
  }
}
