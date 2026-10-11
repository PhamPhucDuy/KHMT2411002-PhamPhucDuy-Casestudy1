import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';
import '../screens/transaction_form_screen.dart';

/// Mở màn hình Thêm (t == null) hoặc Sửa giao dịch.
Future<void> openTransactionForm(BuildContext context,
    [TransactionModel? t]) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => TransactionFormScreen(transaction: t)),
  );
}

class TransactionTile extends StatelessWidget {
  final TransactionModel t;
  const TransactionTile(this.t, {super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
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
    if (ok == true) await DatabaseHelper.instance.delete(t.id!);
    return false; // danh sách sẽ tự tải lại từ DB
  }

  @override
  Widget build(BuildContext context) {
    final cat = findCategory(t.category, t.isIncome);
    final color = t.isIncome ? Colors.green : Colors.red;
    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => openTransactionForm(context, t),
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
