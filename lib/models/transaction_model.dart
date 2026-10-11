class TransactionModel {
  final int? id;
  final String type; // 'expense' hoặc 'income'
  final String category;
  final int amount;
  final DateTime date;
  final String note;

  TransactionModel({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  });

  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
        id: m['id'] as int?,
        type: m['type'] as String,
        category: m['category'] as String,
        amount: m['amount'] as int,
        date: DateTime.parse(m['date'] as String),
        note: (m['note'] as String?) ?? '',
      );
}
