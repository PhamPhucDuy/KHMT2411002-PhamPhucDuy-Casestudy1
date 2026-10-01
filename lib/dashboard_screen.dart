import 'package:flutter/material.dart';
import 'transaction_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu (sẽ thay bằng database SQLite ở Buổi 5 & 6)
    final List<Map<String, dynamic>> mockTransactions = [
      {
        'title': 'Ăn trưa',
        'category': 'Ăn uống',
        'amount': '-100.000đ',
        'date': '12/04/2025',
        'isExpense': true,
        'icon': Icons.restaurant,
      },
      {
        'title': 'Nhận lương',
        'category': 'Thu nhập',
        'amount': '+10.000.000đ',
        'date': '10/04/2025',
        'isExpense': false,
        'icon': Icons.attach_money,
      },
      {
        'title': 'Mua quần áo',
        'category': 'Mua sắm',
        'amount': '-500.000đ',
        'date': '08/04/2025',
        'isExpense': true,
        'icon': Icons.shopping_bag,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chi tiêu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Khung Thống kê tổng quan
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Số dư hiện tại',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '9.400.000đ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: Colors.white38, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.arrow_downward, color: Colors.greenAccent),
                            SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Thu nhập', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text('10.000.000đ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(Icons.arrow_upward, color: Colors.redAccent),
                            SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Chi tiêu', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text('600.000đ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Tiêu đề Danh sách
            const Text(
              'Giao dịch gần đây',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 3. Danh sách các giao dịch gần đây
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockTransactions.length,
              itemBuilder: (context, index) {
                final item = mockTransactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item['isExpense'] ? Colors.red[50] : Colors.green[50],
                      child: Icon(
                        item['icon'],
                        color: item['isExpense'] ? Colors.redAccent : Colors.green,
                      ),
                    ),
                    title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item['category']} • ${item['date']}'),
                    trailing: Text(
                      item['amount'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: item['isExpense'] ? Colors.redAccent : Colors.green,
                      ),
                    ),
                    onTap: () {
                      // Bấm vào 1 item sẽ mở màn hình "Sửa giao dịch"
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionFormScreen(
                            initialAmount: item['amount'].replaceAll('đ', '').replaceAll('+', '').replaceAll('-', ''),
                            initialNote: item['title'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // 4. Nút bấm Thêm giao dịch góc dưới màn hình (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}