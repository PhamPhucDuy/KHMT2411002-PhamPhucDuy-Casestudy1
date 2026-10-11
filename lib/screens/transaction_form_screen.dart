import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/category.dart';
import '../models/transaction_model.dart';

/// Dùng chung cho cả "Thêm giao dịch" (transaction == null)
/// và "Sửa giao dịch" (truyền transaction vào).
class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  static const blue = Color(0xFF1565C0);
  static const red = Color(0xFFEF5350);

  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _isExpense = true;
  late String _category;
  DateTime _date = DateTime.now();

  bool get _isEdit => widget.transaction != null;
  List<Category> get _categories =>
      _isExpense ? expenseCategories : incomeCategories;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _isExpense = !t.isIncome;
      _category = t.category;
      _amountCtrl.text = t.amount.toString();
      _noteCtrl.text = t.note;
      _date = t.date;
    } else {
      _category = _categories.first.name;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _setType(bool expense) {
    setState(() {
      _isExpense = expense;
      _category = _categories.first.name;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final t = TransactionModel(
      id: widget.transaction?.id,
      type: _isExpense ? 'expense' : 'income',
      category: _category,
      amount: int.parse(_amountCtrl.text),
      date: _date,
      note: _noteCtrl.text.trim(),
    );
    if (_isEdit) {
      await DatabaseHelper.instance.update(t);
    } else {
      await DatabaseHelper.instance.insert(t);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget _typeButton(String label, bool expense) {
    final selected = _isExpense == expense;
    final color = expense ? red : Colors.green;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setType(expense),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? color : Colors.grey.shade300),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(8));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(_isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _typeButton('Chi tiêu', true),
                  const SizedBox(width: 8),
                  _typeButton('Thu nhập', false),
                ]),
                _label('Danh mục'),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(border: border),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c.name,
                            child: Row(children: [
                              Icon(c.icon, color: c.color, size: 20),
                              const SizedBox(width: 10),
                              Text(c.name),
                            ]),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                _label('Số tiền'),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      border: border, hintText: 'Nhập số tiền', suffixText: 'đ'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập số tiền';
                    if ((int.tryParse(v) ?? 0) <= 0) {
                      return 'Số tiền phải lớn hơn 0';
                    }
                    return null;
                  },
                ),
                _label('Ngày giao dịch'),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                        border: border,
                        suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                    child: Text(DateFormat('dd/MM/yyyy').format(_date)),
                  ),
                ),
                _label('Ghi chú'),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                      border: border, hintText: 'Nhập ghi chú (tùy chọn)'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _save,
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
