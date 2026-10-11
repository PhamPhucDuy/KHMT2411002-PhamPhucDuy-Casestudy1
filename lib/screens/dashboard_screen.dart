import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../db/transaction_loader.dart';
import '../models/category.dart';
import '../models/spending.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  /// Bấm "Xem tất cả" -> chuyển sang tab Giao dịch
  final VoidCallback? onSeeAll;
  const DashboardScreen({super.key, this.onSeeAll});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TransactionLoader<DashboardScreen> {
  static const blue = Color(0xFF1565C0);
  Map<String, String> _settings = {};

  @override
  Future<void> reload() async {
    await super.reload();
    try {
      final s = await DatabaseHelper.instance.getAllSettings();
      if (!mounted) return;
      setState(() => _settings = s);
    } catch (_) {}
  }

  int get _income =>
      items.where((e) => e.isIncome).fold(0, (s, e) => s + e.amount);
  int get _expense =>
      items.where((e) => !e.isIncome).fold(0, (s, e) => s + e.amount);

  List<Widget> _banners() {
    final list = <Widget>[];
    final now = DateTime.now();

    final budget = int.tryParse(_settings['budget_monthly'] ?? '') ?? 0;
    if (budget > 0 && _settings['alert_budget'] != '0') {
      final spent = monthExpense(items, now);
      final pct = (spent * 100 / budget).round();
      if (spent >= budget) {
        list.add(_banner(
            'Bạn đã chi $pct% ngân sách tháng này (vượt ${formatMoney(spent - budget)})',
            Colors.red,
            Icons.warning_amber_rounded));
      } else if (pct >= 80) {
        list.add(_banner('Bạn đã chi $pct% ngân sách tháng này',
            Colors.orange, Icons.info_outline));
      }
    }

    if (_settings['remind_daily'] == '1') {
      final hasToday = items.any((t) =>
      t.date.year == now.year &&
          t.date.month == now.month &&
          t.date.day == now.day);
      if (!hasToday) {
        list.add(_banner(
            'Hôm nay bạn chưa ghi giao dịch nào', blue, Icons.edit_note));
      }
    }
    return list;
  }

  Widget _banner(String text, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = items.take(5).toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        onPressed: () => openTransactionForm(context),
        child: const Icon(Icons.add),
      ),
      body: statusWidget() ??
          RefreshIndicator(
            onRefresh: reload,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _header(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._banners(),
                      Row(children: [
                        Expanded(
                            child: _summaryCard('Thu nhập', _income,
                                Icons.arrow_upward, Colors.green)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _summaryCard('Chi tiêu', _expense,
                                Icons.arrow_downward, Colors.red)),
                      ]),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Chi tiêu gần đây',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          TextButton(
                            onPressed: widget.onSeeAll,
                            child: const Text('Xem tất cả'),
                          ),
                        ],
                      ),
                      if (recent.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text('Chưa có giao dịch nào',
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ...recent.map((t) => TransactionTile(t)),
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _header() {
    final name = (_settings['user_name'] ?? '').trim();
    return Container(
      width: double.infinity,
      color: blue,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isEmpty ? 'Xin chào!' : 'Xin chào, $name!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const Text('Hôm nay là một ngày tốt lành!',
                          style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Số dư hiện tại',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(formatMoney(_income - _expense),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.account_balance_wallet, color: blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, int amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(formatMoney(amount),
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
