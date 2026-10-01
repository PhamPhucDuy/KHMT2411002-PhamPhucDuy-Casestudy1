class TransactionModel {
  final int? id;          // Mã giao dịch (Auto increment trong SQLite)
  final String title;     // Ghi chú / Tên giao dịch
  final double amount;    // Số tiền
  final String date;      // Ngày thực hiện (định dạng DD/MM/YYYY)
  final String category;  // Danh mục (Ăn uống, Mua sắm,...)
  final bool isExpense;   // true: Chi tiêu, false: Thu nhập

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isExpense,
  });

  // 1. Chuyển từ Object Dart -> Map (để lưu vào SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'category': category,
      'isExpense': isExpense ? 1 : 0, // SQLite không có kiểu bool, dùng 1 và 0
    };
  }

  // 2. Chuyển từ Map (đọc từ SQLite) -> Object Dart (để dùng trong ứng dụng)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: map['date'],
      category: map['category'],
      isExpense: map['isExpense'] == 1,
    );
  }
}