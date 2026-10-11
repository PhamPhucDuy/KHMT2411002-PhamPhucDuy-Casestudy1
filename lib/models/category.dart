import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;
  const Category(this.name, this.icon, this.color);
}

const expenseCategories = [
  Category('Ăn uống', Icons.restaurant, Color(0xFFEF5350)),
  Category('Mua sắm', Icons.shopping_cart, Color(0xFF26A6C9)),
  Category('Đi lại', Icons.directions_car, Color(0xFF7E57C2)),
  Category('Học tập', Icons.menu_book, Color(0xFF5C6BC0)),
  Category('Khác', Icons.more_horiz, Color(0xFF78909C)),
];

const incomeCategories = [
  Category('Lương', Icons.account_balance_wallet, Color(0xFF43A047)),
  Category('Thưởng', Icons.card_giftcard, Color(0xFFFFA000)),
  Category('Khác', Icons.more_horiz, Color(0xFF78909C)),
];

Category findCategory(String name, bool isIncome) {
  final list = isIncome ? incomeCategories : expenseCategories;
  return list.firstWhere((c) => c.name == name, orElse: () => list.last);
}

String formatMoney(int amount) =>
    '${NumberFormat('#,###', 'vi_VN').format(amount)} đ';
