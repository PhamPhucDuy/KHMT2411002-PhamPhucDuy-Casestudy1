import 'package:flutter/material.dart';
import 'transaction_model.dart';

class TransactionFilter {
  final String type; // 'all' | 'expense' | 'income'
  final Set<String> categories;
  final DateTimeRange? range;

  const TransactionFilter({
    this.type = 'all',
    this.categories = const {},
    this.range,
  });

  bool get isActive => type != 'all' || categories.isNotEmpty || range != null;

  TransactionFilter withType(String newType) =>
      TransactionFilter(type: newType, categories: categories, range: range);

  bool matches(TransactionModel t) {
    if (type == 'income' && !t.isIncome) return false;
    if (type == 'expense' && t.isIncome) return false;
    if (categories.isNotEmpty && !categories.contains(t.category)) return false;
    final r = range;
    if (r != null) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      final s = DateTime(r.start.year, r.start.month, r.start.day);
      final e = DateTime(r.end.year, r.end.month, r.end.day);
      if (d.isBefore(s) || d.isAfter(e)) return false;
    }
    return true;
  }
}
