import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
import 'transaction_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const blue = Color(0xFF1565C0);
  List<TransactionModel> _items = [];
  bool _loading = true;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAll();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  int get _income =>
      _items.where((e) => e.isIncome).fold(0, (s, e) => s + e.amount);
  int get _expense =>
      _items.where((e) => !e.isIncome).fold(0, (s, e) => s + e.amount);

  Future<void> _openForm([TransactionModel? t]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TransactionFormScreen(transaction: t)),
    );
    if (changed == true) _load();
  }

  Future<bool> _confirmDelete(TransactionModel t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.delete(t.id!);
      await _load();
    }
    return false; // danh sách đã được load lại từ DB
  }

  @override
  Widget build(BuildContext context) {
    final shown = _showAll ? _items : _items.take(5).toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _header(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            if (_items.length > 5)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _showAll = !_showAll),
                                child:
                                    Text(_showAll ? 'Thu gọn' : 'Xem tất cả'),
                              ),
                          ],
                        ),
                        if (shown.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text('Chưa có giao dịch nào',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        ...shown.map(_tile),
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
    return Container(
      width: double.infinity,
      color: blue,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xin chào!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const Text('Hôm nay là một ngày tốt lành!',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(14)),
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

  Widget _tile(TransactionModel t) {
    final cat = findCategory(t.category, t.isIncome);
    final color = t.isIncome ? Colors.green : Colors.red;
    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(t),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => _openForm(t),
        leading: CircleAvatar(
          backgroundColor: cat.color.withValues(alpha: 0.15),
          child: Icon(cat.icon, color: cat.color, size: 20),
        ),
        title: Text(t.category,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(t.date)}'
          '${t.note.isEmpty ? '' : ' • ${t.note}'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${t.isIncome ? '+' : '-'}${formatMoney(t.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
