import 'dart:math';
import 'package:flutter/material.dart';
import '../db/transaction_loader.dart';
import '../models/category.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TransactionLoader<StatisticsScreen> {
  static const blue = Color(0xFF1565C0);
  static const _tabs = ['Tháng này', 'Tháng trước', 'Năm nay'];
  int _tab = 0;

  DateTimeRange get _range {
    final now = DateTime.now();
    switch (_tab) {
      case 1:
        return DateTimeRange(
            start: DateTime(now.year, now.month - 1, 1),
            end: DateTime(now.year, now.month, 1));
      case 2:
        return DateTimeRange(
            start: DateTime(now.year, 1, 1), end: DateTime(now.year + 1, 1, 1));
      default:
        return DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month + 1, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _range;
    final inRange = items
        .where((t) => !t.date.isBefore(r.start) && t.date.isBefore(r.end))
        .toList();

    final byCategory = <String, int>{};
    int income = 0;
    for (final t in inRange) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      }
    }
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalExpense = entries.fold(0, (s, e) => s + e.value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: statusWidget() ??
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = _tab == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        height: 38,
                        margin: EdgeInsets.only(right: i == 2 ? 0 : 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? blue : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: selected ? blue : Colors.grey.shade300),
                        ),
                        child: Text(_tabs[i],
                            style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 210,
                  height: 210,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(210, 210),
                        painter: _DonutPainter(
                          entries.map((e) => e.value.toDouble()).toList(),
                          entries
                              .map((e) => findCategory(e.key, false).color)
                              .toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(formatMoney(totalExpense),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Tổng chi tiêu',
                              style:
                              TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _box('Thu nhập', income, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _box('Chi tiêu', totalExpense, Colors.red)),
              ]),
              const SizedBox(height: 20),
              const Text('Chi tiêu theo danh mục',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Chưa có chi tiêu trong khoảng này',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ...entries.map((e) {
                final cat = findCategory(e.key, false);
                final percent = totalExpense == 0
                    ? 0
                    : (e.value * 100 / totalExpense).round();
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: cat.color.withValues(alpha: 0.15),
                    child: Icon(cat.icon, color: cat.color, size: 20),
                  ),
                  title: Text(e.key,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('$percent%'),
                  trailing: Text(formatMoney(e.value),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }),
            ],
          ),
    );
  }

  Widget _box(String label, int amount, Color color) => Container(
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
        Text(formatMoney(amount),
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    ),
  );
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _DonutPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 28.0;
    final rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.grey.shade200;
    canvas.drawArc(rect, 0, 2 * pi, false, base);

    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    double start = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * pi;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors[i];
      canvas.drawArc(rect, start, sweep, false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}
