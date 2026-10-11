import 'package:flutter/material.dart';
import '../db/transaction_loader.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_tile.dart';
import 'filter_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TransactionLoader<TransactionsScreen> {
  static const blue = Color(0xFF1565C0);

  final _searchCtrl = TextEditingController();
  TransactionFilter _filter = const TransactionFilter();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TransactionModel> get _visible {
    final q = _query.trim().toLowerCase();
    return items.where((t) {
      if (!_filter.matches(t)) return false;
      if (q.isEmpty) return true;
      return t.category.toLowerCase().contains(q) ||
          t.note.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<TransactionFilter>(
      context,
      MaterialPageRoute(builder: (_) => FilterScreen(initial: _filter)),
    );
    if (result != null) setState(() => _filter = result);
  }

  Widget _tab(String label, String value) {
    final selected = _filter.type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = _filter.withType(value)),
        child: Container(
          height: 38,
          margin: const EdgeInsets.only(right: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? blue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? blue : Colors.grey.shade300),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _visible;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: statusWidget() ??
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm giao dịch...',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: _openFilter,
                      icon: Badge(
                        smallSize: 8,
                        isLabelVisible: _filter.isActive,
                        child: const Icon(Icons.filter_list),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                child: Row(children: [
                  _tab('Tất cả', 'all'),
                  _tab('Thu nhập', 'income'),
                  _tab('Chi tiêu', 'expense'),
                ]),
              ),
              Expanded(
                child: list.isEmpty
                    ? const Center(
                    child: Text('Không có giao dịch nào',
                        style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                  onRefresh: reload,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (_, i) => TransactionTile(list[i]),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
