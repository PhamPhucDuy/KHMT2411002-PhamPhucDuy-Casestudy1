import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/database_helper.dart';
import '../db/transaction_loader.dart';
import '../models/category.dart';
import '../models/spending.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with TransactionLoader<BudgetScreen> {
  static const blue = Color(0xFF1565C0);
  final _ctrl = TextEditingController();
  int _budget = 0;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadBudget() async {
    final s = await DatabaseHelper.instance.getAllSettings();
    if (!mounted) return;
    setState(() {
      _budget = int.tryParse(s['budget_monthly'] ?? '') ?? 0;
      _ctrl.text = _budget > 0 ? _budget.toString() : '';
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final value = int.tryParse(_ctrl.text) ?? 0;
    await DatabaseHelper.instance
        .setSetting('budget_monthly', value.toString());
    if (!mounted) return;
    setState(() => _budget = value);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value > 0 ? 'Đã lưu ngân sách tháng' : 'Đã tắt ngân sách')));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final spent = monthExpense(items, now);
    final ratio = _budget > 0 ? spent / _budget : 0.0;
    final color = ratio >= 1
        ? Colors.red
        : ratio >= 0.8
        ? Colors.orange
        : Colors.green;
    final remaining = _budget - spent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt ngân sách',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: statusWidget() ??
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Ngân sách chi tiêu hàng tháng',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  hintText: 'Nhập số tiền (để trống = không đặt ngân sách)',
                  suffixText: 'đ',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _save,
                  child: const Text('Lưu'),
                ),
              ),
              if (_budget > 0) ...[
                const SizedBox(height: 28),
                Text('Tháng ${now.month}/${now.year}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 12,
                    color: color,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Đã dùng ${(ratio * 100).round()}% ngân sách',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _box('Đã chi', formatMoney(spent), Colors.red)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: remaining >= 0
                        ? _box('Còn lại', formatMoney(remaining), Colors.green)
                        : _box('Vượt ngân sách', formatMoney(-remaining),
                        Colors.red),
                  ),
                ]),
              ],
            ],
          ),
    );
  }

  Widget _box(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    ),
  );
}
