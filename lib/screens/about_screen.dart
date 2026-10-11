import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _feature(IconData icon, String text) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: const Color(0xFF1565C0), size: 22),
    title: Text(text),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giới thiệu ứng dụng',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.account_balance_wallet_rounded,
              size: 80, color: Color(0xFF1565C0)),
          const SizedBox(height: 12),
          const Center(
            child: Text('Expense Manager',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const Center(
            child: Text('Phiên bản 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ứng dụng quản lý chi tiêu cá nhân đơn giản và hiệu quả, '
                'giúp bạn ghi lại thu chi mỗi ngày và theo dõi tình hình tài chính.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text('Tính năng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          _feature(Icons.add_circle_outline, 'Thêm, sửa, xóa giao dịch'),
          _feature(Icons.search, 'Tìm kiếm và lọc giao dịch'),
          _feature(Icons.pie_chart_outline, 'Thống kê chi tiêu theo danh mục'),
          _feature(Icons.savings_outlined, 'Đặt ngân sách và theo dõi hàng tháng'),
          const SizedBox(height: 16),
          const Text('Công nghệ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          _feature(Icons.flutter_dash, 'Flutter'),
          _feature(Icons.storage, 'SQLite (sqflite)'),
        ],
      ),
    );
  }
}
