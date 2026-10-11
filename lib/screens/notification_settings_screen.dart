import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _budgetAlert = true;
  bool _remind = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await DatabaseHelper.instance.getAllSettings();
    if (!mounted) return;
    setState(() {
      _budgetAlert = s['alert_budget'] != '0'; // mặc định bật
      _remind = s['remind_daily'] == '1'; // mặc định tắt
      _loading = false;
    });
  }

  Future<void> _setBudgetAlert(bool v) async {
    setState(() => _budgetAlert = v);
    await DatabaseHelper.instance.setSetting('alert_budget', v ? '1' : '0');
  }

  Future<void> _setRemind(bool v) async {
    setState(() => _remind = v);
    await DatabaseHelper.instance.setSetting('remind_daily', v ? '1' : '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          SwitchListTile(
            value: _budgetAlert,
            onChanged: _setBudgetAlert,
            title: const Text('Cảnh báo ngân sách'),
            subtitle: const Text(
                'Hiện cảnh báo ở Trang chủ khi chi tiêu tháng này đạt 80% hoặc vượt ngân sách'),
          ),
          SwitchListTile(
            value: _remind,
            onChanged: _setRemind,
            title: const Text('Nhắc ghi chép hằng ngày'),
            subtitle: const Text(
                'Hiện nhắc nhở ở Trang chủ nếu hôm nay bạn chưa thêm giao dịch nào'),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Các nhắc nhở hiển thị bên trong ứng dụng khi bạn mở app.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
