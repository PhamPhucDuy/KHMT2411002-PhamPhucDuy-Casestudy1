import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'database_helper.dart';

/// Dùng chung cho các màn hình cần đọc danh sách giao dịch từ SQLite.
/// Tự tải lại khi dữ liệu thay đổi và hiển thị lỗi thay vì xoay mãi.
mixin TransactionLoader<T extends StatefulWidget> on State<T> {
  List<TransactionModel> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.changes.addListener(reload);
    reload();
  }

  @override
  void dispose() {
    DatabaseHelper.instance.changes.removeListener(reload);
    super.dispose();
  }

  Future<void> reload() async {
    try {
      final data = await DatabaseHelper.instance.getAll();
      if (!mounted) return;
      setState(() {
        items = data;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  /// Trả về widget "đang tải" hoặc "lỗi"; null nếu dữ liệu đã sẵn sàng.
  Widget? statusWidget() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Không đọc được dữ liệu:\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: reload, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }
    return null;
  }
}
