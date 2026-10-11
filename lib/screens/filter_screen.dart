import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction_filter.dart';

class FilterScreen extends StatefulWidget {
  final TransactionFilter initial;
  const FilterScreen({super.key, required this.initial});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const blue = Color(0xFF1565C0);

  late String _type;
  late Set<String> _cats;
  DateTimeRange? _range;

  final List<String> _allCategoryNames = {
    ...expenseCategories.map((c) => c.name),
    ...incomeCategories.map((c) => c.name),
  }.toList();

  @override
  void initState() {
    super.initState();
    _type = widget.initial.type;
    _cats = {...widget.initial.categories};
    _range = widget.initial.range;
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Widget _typeOption(String label, String value) {
    final selected = _type == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: () => setState(() => _type = value),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? blue : Colors.grey,
      ),
      title: Text(label),
    );
  }

  Widget _section(String s) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ lọc',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Loại giao dịch'),
          _typeOption('Tất cả', 'all'),
          _typeOption('Thu nhập', 'income'),
          _typeOption('Chi tiêu', 'expense'),
          _section('Danh mục'),
          Wrap(
            spacing: 8,
            children: _allCategoryNames
                .map((name) => FilterChip(
              label: Text(name),
              selected: _cats.contains(name),
              onSelected: (v) => setState(() {
                v ? _cats.add(name) : _cats.remove(name);
              }),
            ))
                .toList(),
          ),
          _section('Khoảng thời gian'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: _pickRange,
            leading: const Icon(Icons.date_range),
            title: Text(_range == null
                ? 'Chọn khoảng ngày'
                : '${f.format(_range!.start)} - ${f.format(_range!.end)}'),
            trailing: _range == null
                ? null
                : IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _range = null),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _type = 'all';
                    _cats.clear();
                    _range = null;
                  }),
                  child: const Text('Đặt lại'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: blue),
                  onPressed: () => Navigator.pop(
                    context,
                    TransactionFilter(
                        type: _type, categories: _cats, range: _range),
                  ),
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
