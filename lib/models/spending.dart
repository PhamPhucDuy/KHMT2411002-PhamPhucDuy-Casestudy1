import 'transaction_model.dart';

/// Tổng chi tiêu trong tháng của ngày [now].
int monthExpense(List<TransactionModel> items, DateTime now) {
  return items
      .where((t) =>
  !t.isIncome && t.date.year == now.year && t.date.month == now.month)
      .fold(0, (sum, t) => sum + t.amount);
}
